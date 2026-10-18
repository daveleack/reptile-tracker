package com.example.reptiletracker.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.reptiletracker.data.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ReptileViewModel @Inject constructor(
    private val repository: PetRepository
) : ViewModel() {

    val petsWithLogs: StateFlow<Map<Pet, List<LogEntry>>> = combine(
        repository.allPets,
        repository.allLogs
    ) { pets, logs ->
        pets.associateWith { pet -> logs.filter { it.petId == pet.id } }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyMap()
    )

    fun addFeedingLog(
        petId: Long,
        foodType: String,
        weightGrams: Float?,
        reaction: FeedingReaction,
        notes: String?
    ) {
        viewModelScope.launch {
            val log = LogEntry(
                petId = petId,
                timestamp = System.currentTimeMillis(),
                type = LogType.FEEDING,
                foodType = foodType,
                weightGrams = weightGrams,
                feedingReaction = reaction,
                notes = notes
            )
            repository.addLog(log)
        }
    }
}
