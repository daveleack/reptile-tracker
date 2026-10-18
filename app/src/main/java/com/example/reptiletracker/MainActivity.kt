package com.example.reptiletracker

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.example.reptiletracker.data.Pet
import com.example.reptiletracker.ui.*
import com.example.reptiletracker.util.CalendarUtils
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val viewModel: ReptileViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val petsWithLogs by viewModel.petsWithLogs.collectAsState()
                    var selectedPetForFeeding by remember { mutableStateOf<Pet?>(null) }
                    var selectedPetForSchedule by remember { mutableStateOf<Pet?>(null) }
                    var petToRename by remember { mutableStateOf<Pet?>(null) }
                    var showAddPetDialog by remember { mutableStateOf(false) }

                    MultiPetTimelineScreen(
                        petsWithLogs = petsWithLogs,
                        onAddPetClick = { showAddPetDialog = true },
                        onRenamePetClick = { pet -> petToRename = pet },
                        onAddLogClick = { pet -> selectedPetForFeeding = pet },
                        onScheduleClick = { pet -> selectedPetForSchedule = pet }
                    )

                    if (showAddPetDialog) {
                        AddPetDialog(
                            onDismiss = { showAddPetDialog = false },
                            onSubmit = { name, species ->
                                viewModel.addPet(name, species)
                                showAddPetDialog = false
                            }
                        )
                    }

                    petToRename?.let { pet ->
                        RenamePetDialog(
                            pet = pet,
                            onDismiss = { petToRename = null },
                            onSubmit = { newName ->
                                viewModel.renamePet(pet, newName)
                                petToRename = null
                            }
                        )
                    }

                    selectedPetForFeeding?.let { pet ->
                        AddFeedingLogDialog(
                            petName = pet.name,
                            onDismiss = { selectedPetForFeeding = null },
                            onSubmit = { foodType, weight, reaction, notes ->
                                viewModel.addFeedingLog(
                                    petId = pet.id,
                                    foodType = foodType,
                                    weightGrams = weight,
                                    reaction = reaction,
                                    notes = notes
                                )
                                selectedPetForFeeding = null
                            }
                        )
                    }

                    selectedPetForSchedule?.let { pet ->
                        ScheduleTaskDialog(
                            petName = pet.name,
                            onDismiss = { selectedPetForSchedule = null },
                            onSubmit = { taskName, daysFromNow, syncWithGoogle ->
                                val dueDate = System.currentTimeMillis() + (daysFromNow * 24 * 60 * 60 * 1000L)
                                if (syncWithGoogle) {
                                    CalendarUtils.addScheduleToGoogleCalendar(
                                        context = this@MainActivity,
                                        pet = pet,
                                        taskName = taskName,
                                        dueDateMillis = dueDate
                                    )
                                }
                                selectedPetForSchedule = null
                            }
                        )
                    }
                }
            }
        }
    }
}