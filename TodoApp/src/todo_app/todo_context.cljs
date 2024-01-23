(ns todo-app.todo-context
  (:require [uix.core :as uix :refer [defui $]]
            [promesa.core :as p]
            [todo-app.todo-api :as todo-api]))

(def TodoContext (uix/create-context nil))

(defn ^:export useTodos []
  (uix/use-context TodoContext))

(defn todo-reducer [todos action]
  (-> (case (:type action)
        :set (:todos action)
        :add (conj todos (:todo action))
        :remove (remove #(= (:todo action) %) todos)
        :toggle (mapv #(if (= (:todo action) %)
                         (assoc % :done (not (:done %)))
                         %)
                      todos)
        todos)))

(defn sync-todos [set-todos]
  (js/console.log "syncing todos")
  ;; Find the todos that are modified and sync them
  (p/-> (todo-api/get-todos)
        (p/then set-todos)))

(defui todo-provider
  "This is our react native app wrapper so we can have our context and business
  logic written in clojure"
  [{:keys [children]}]
  (let [[todos, dispatch] (uix/use-reducer todo-reducer [])
        set-todos (fn [new-state]
                    (let [new-todos (if (fn? new-state)
                                      (new-state todos)
                                      new-state)]
                      (dispatch {:type :set :todos new-todos})))
        perform-sync (partial sync-todos set-todos)
        context {:todos todos
                 :setTodos set-todos
                 :performSync perform-sync}]

    (uix/use-effect
     (fn [] (perform-sync)
       ;; Optionaly sync in regular intervals
       ;;(js/setInterval perform-sync 10000)
       )[]) ;; perform-sync on mount

    ;; The todo business logic goes here
    ($ TodoContext.Provider
       (clj->js {:value context})
       children)))
