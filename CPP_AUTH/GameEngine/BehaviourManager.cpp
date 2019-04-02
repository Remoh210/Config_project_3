#include "BehaviourManager.h"
#include "cMeshObject.h"

BehaviourManager::BehaviourManager(void) {

}

BehaviourManager::~BehaviourManager(void) {
	// Perform cleanup
	for (behaviour_iterator itAgent = mBehaviourMap.begin();
		itAgent != mBehaviourMap.end(); itAgent++) {
		if (itAgent->second != 0) {
			delete itAgent->second;
		}
	}
	mBehaviourMap.clear();
}

void BehaviourManager::SetBehaviour(cMeshObject* agent, Behaviour* behaviour) {
	// Check if the agent is already in the behaviour map
	behaviour_iterator itAgent = mBehaviourMap.find(agent);

	// If the agent is in the map, and there is already a behaviour then delete 
	// the behaviour
	if (itAgent != mBehaviourMap.end() && itAgent->second != 0) {
		delete itAgent->second;
	}

	mBehaviourMap[agent] = behaviour;
}

void BehaviourManager::RemoveAgent(cMeshObject* agent) {
	// Check if the agent is in the map
	behaviour_iterator itAgent = mBehaviourMap.find(agent);

	// if the agent is in the map, delete the behaviour, and remove the agent.
	if (itAgent != mBehaviourMap.end()) {
		if (itAgent->second != 0) {
			delete itAgent->second;
		}
		mBehaviourMap.erase(itAgent);
	}
}

void BehaviourManager::update(float dt) {
	for (behaviour_iterator itAgent = mBehaviourMap.begin();
		itAgent != mBehaviourMap.end(); itAgent++) {
		if (itAgent->second != 0 && itAgent->first->bIsVisible == true) {
			itAgent->second->update(dt);
		}
	}
}