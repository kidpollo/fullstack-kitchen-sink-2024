(ns todo-app.todo-context
  (:require [uix.core :as uix :refer [defui $]]))

(def TodoContext (uix/create-context nil))

(defn ^:export useTodos []
  (uix/use-context TodoContext))

(defui todo-provider
  "This is our react native app wrapper so we can have our context and business
  logic written in clojure"
  [{:keys [children]}]
  (let [[todos, _set-todos] (uix/use-state [])]
    ;; The todo business logic goes here
    ($ TodoContext.Provider (clj->js {:value
                                      {:todos todos
                                       :fn (fn [] (js/console.log "hello"))}})
       children)))
