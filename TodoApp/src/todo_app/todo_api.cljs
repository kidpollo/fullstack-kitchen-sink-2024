(ns todo-app.todo-api
  (:require [promesa.core :as p]))

(def config (js/require "react-native-config"))

(def todo-api-url (get-in (js->clj config) ["Config" "TODO_API_URL"]))

(defn get-todos []
  (p/-> (js/fetch todo-api-url
                  (clj->js {:method "GET"}))
        (p/then #(.json %))))

(defn create-todo [todo]
  (p/-> (js/fetch todo-api-url
                  (clj->js {:method "POST"
                            :body (js/JSON.stringify todo)
                            :headers {"Content-Type" "application/json"}}))
        (p/then #(.json %))))

(defn update-todo [todo]
  (p/-> (js/fetch (str todo-api-url "/" (get (js->clj todo) "id"))
                  (clj->js {:method "PUT"
                            :body (js/JSON.stringify todo)
                            :headers {"Content-Type" "application/json"}}))
        (p/then #(.json %))))

(defn delete-todo [todo]
  (p/-> (js/fetch (str todo-api-url "/" (get (js->clj todo) "id"))
                  (clj->js {:method "DELETE"}))
        (p/then #(.json %))))
