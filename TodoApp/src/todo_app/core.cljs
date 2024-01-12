(ns todo-app.core
  (:require [uix.core :refer [#_defui $]]
            #_[react-native :as rn]))

(defn ^:export -main
  "This is our react native app wrapper so we can have out context and business
  logic written in clojure"
  [& _args]
  ($ (.-default (js/require "../../App.tsx"))))