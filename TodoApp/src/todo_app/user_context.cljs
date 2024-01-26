(ns todo-app.user-context
  (:require [uix.core :as uix :refer [defui $]]))

(def UserContext (uix/create-context nil))

(defn ^:export useUser
  "Hooks for using the user context"
  []
  (uix/use-context UserContext))

(defui user-provider
  "User state provider business logic written in clojure script"
  [{:keys [children]}]
  (let [[user set-current-user] (uix/use-state nil #_(clj->js {:username "Guest"}))
        login (fn [username]
                (set-current-user (clj->js {:username username})))
        logout (fn [] (set-current-user nil))
        context {:user user
                 :login login
                 :logout logout
                 :setUser set-current-user}]
    ($ UserContext.Provider
       (clj->js {:value context})
       children)))
