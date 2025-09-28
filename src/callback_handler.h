#pragma once

#include <functional>
#include <map>
#include <vector>
#include "property.h"
#include "simple_variant.h"
#include "communication.h"

class CallbackHandler {
public:
    using CallbackFunction = std::function<void(const SimpleVariant&)>;
    using CallbackKey = std::pair<CanMember, Property>;
    
    static CallbackHandler& instance() {
        static CallbackHandler instance;
        return instance;
    }
    
    void addCallback(const CallbackKey& key, CallbackFunction callback) {
        callbacks_[key] = callback;
    }
    
    void addCallbacks(const std::vector<CallbackKey>& keys, CallbackFunction callback) {
        for (const auto& key : keys) {
            callbacks_[key] = callback;
        }
    }
    
    CallbackFunction getCallback(const CallbackKey& key) {
        auto it = callbacks_.find(key);
        if (it != callbacks_.end()) {
            return it->second;
        }
        // Return default callback that does nothing
        return [](const SimpleVariant&) {};
    }
    
private:
    std::map<CallbackKey, CallbackFunction> callbacks_;
    
    CallbackHandler() = default;
    CallbackHandler(const CallbackHandler&) = delete;
    CallbackHandler& operator=(const CallbackHandler&) = delete;
};