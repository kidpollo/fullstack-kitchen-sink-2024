(ns todo-app.todo-api
  (:require [promesa.core :as p]))

(def todo-api-url "https://jkbzi1llhc.execute-api.us-west-2.amazonaws.com/todo")

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
