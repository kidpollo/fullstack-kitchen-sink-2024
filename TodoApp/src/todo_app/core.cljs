(ns todo-app.core
  (:require [uix.core :refer [#_defui $]]
            #_[react-native :as rn]))

(def gluestack-themed (js/require "@gluestack-ui/themed"))
(def gluestack-provider (.-GluestackUIProvider gluestack-themed))
(def gluestack-config (.-config (js/require "@gluestack-ui/config")))

(defn ^:export -main
  "This is our react native app wrapper so we can have out context and business
  logic written in clojure"
  [& _args]
  ($ gluestack-provider
     {:config gluestack-config}
     ($ (.-default (js/require "../../App.tsx")))))
