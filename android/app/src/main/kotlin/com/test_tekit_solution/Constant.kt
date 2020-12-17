package com.test_tekit_solution

class Constant {
    interface ACTION {
        companion object {
            const val STARTFOREGROUND_ACTION = "ACTION_START_FOREGROUND_SERVICE"
            const val STOPFOREGROUND_ACTION = "ACTION_STOP_FOREGROUND_SERVICE"
            const val MAIN_ACTION = "ACTION_MAIN"
            
            
             var destinationLat : Double ?= 0.0 
             var destinationLong : Double ?= 0.0 
        }
    }
}