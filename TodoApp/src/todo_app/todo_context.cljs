(ns todo-app.todo-context
  (:require [uix.core :as uix :refer [defui $]]
            [promesa.core :as p]
            [todo-app.todo-api :as todo-api]))

;; NOTE: All the messy clj to js conversion stuff can be cleaned up
;; with https://github.com/applied-science/js-interop

(def TodoContext (uix/create-context nil))

(defn ^:export useTodos
  "Hooks for using the todo context"
  []
  (uix/use-context TodoContext))

(defn todo-reducer
  "Updates the todos based on the action"
  [todos action]
  (->> (case (:type action)
         :set (:todos action)
         ;; We really arent using other actions but this is how you would do it
         :add (conj todos (:todo action))
         :remove (remove #(= (:todo action) %) todos)
         :toggle (mapv #(if (= (:todo action) %)
                          (assoc % :done (not (:done %)))
                          %)
                       todos)
         todos)
       (sort-by #(get (js->clj %) "created_at"))
       clj->js))

(defn sync-todos
  "Gets new and modified todos and sync them with the server"
  [set-todos set-is-syncing current-todos]
  (set-is-syncing true)
  (p/let [new-todos (filter #(get (js->clj %) "newTodo") current-todos)
          modified-todos (filter #(get (js->clj %) "modified") current-todos)
          deleted-todos (filter #(get (js->clj %) "deleted") current-todos)
          _ (p/all (map #(todo-api/create-todo %) new-todos))
          _ (p/all (map #(todo-api/update-todo %) modified-todos))
          _ (p/all (map #(todo-api/delete-todo %) deleted-todos))
          synced-todos (todo-api/get-todos)
          _ (set-todos synced-todos)]
    (set-is-syncing false)))

(defui todo-provider
  "Todo state provider business logic written in clojure script"
  [{:keys [children]}]
  (let [[todos, dispatch] (uix/use-reducer todo-reducer [])
        [is-syncing, set-is-syncing] (uix/use-state false)
        ;; Simple wrapper around sync-todos to apply local changes and sync
        set-todos (fn [new-state]
                    (let [new-todos (if (fn? new-state)
                                      (new-state todos)
                                      new-state)]
                      (sync-todos #(dispatch {:type :set :todos %}) set-is-syncing new-todos)))
        context {:todos todos ;; The todos state
                 :setTodos set-todos ;; Wrapper around sync-todos that works with local state
                 :isSyncing is-syncing}]

    (uix/use-effect
     (fn []
       ;; Sync todos on mount
       (set-todos todos)
       ;; Optionaly sync in regular intervals
       ;;(js/setInterval perform-sync 10000)
       )[]) ;; perform-sync on mount

    ;; The todo business logic goes here
    ($ TodoContext.Provider
       (clj->js {:value context})
       children)))
