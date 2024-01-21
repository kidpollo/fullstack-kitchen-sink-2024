(ns todo-app.todo-context
  (:require [uix.core :as uix :refer [defui $]]))

(def TodoContext (uix/create-context nil))

(defn ^:export useTodos []
  (uix/use-context TodoContext))

(defui todo-provider
  "This is our react native app wrapper so we can have our context and business
  logic written in clojure"
  [{:keys [children]}]
  (let [[todos, set-todos] (uix/use-state [])
        perform-sync (fn [] (js/console.log "syncing todos"))
        context {:todos todos
                 :setTodos set-todos
                 :performSync perform-sync}]

    (uix/use-effect
     (fn [] (perform-sync)
       ;; Optionaly sync in regular intervals
       ;;(js/setInterval perform-sync 10000)
       ) []) ;; perform-sync on mount

    ;; The todo business logic goes here
    ($ TodoContext.Provider
       (clj->js {:value context})
       children)))
