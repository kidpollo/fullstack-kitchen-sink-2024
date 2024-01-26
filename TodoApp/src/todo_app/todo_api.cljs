(ns todo-app.todo-api
  (:require [promesa.core :as p]))

(def config (js/require "react-native-config"))

(def todo-api-url
  "API Gateway URL
  We are relying on simulated auhentation using username as the token."
  (get-in (js->clj config) ["Config" "TODO_API_URL"]))

(defn get-todos [user]
  (p/-> (js/fetch todo-api-url
                  (clj->js {:method "GET"
                            :headers {"Content-Type" "application/json"
                                      "Authorization" (str "Bearer " (get user "username"))}}))
        (p/then #(.json %))))

(defn create-todo [todo user]
  (p/-> (js/fetch todo-api-url
                  (clj->js {:method "POST"
                            :body (js/JSON.stringify todo)
                            :headers {"Content-Type" "application/json"
                                      "Authorization" (str "Bearer " (get user "username"))}}))
        (p/then #(.json %))))

(defn update-todo [todo user]
  (p/-> (js/fetch (str todo-api-url "/" (get (js->clj todo) "id"))
                  (clj->js {:method "PUT"
                            :body (js/JSON.stringify todo)
                            :headers {"Content-Type" "application/json"
                                      "Authorization" (str "Bearer " (get user "username"))}}))
        (p/then #(.json %))))

(defn delete-todo [todo user]
  (p/-> (js/fetch (str todo-api-url "/" (get (js->clj todo) "id"))
                  (clj->js {:method "DELETE"
                            :headers {"Content-Type" "application/json"
                                      "Authorization" (str "Bearer " (get user "username"))}}))
        (p/then #(.json %))))
