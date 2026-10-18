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
import com.example.reptiletracker.ui.AddFeedingLogDialog
import com.example.reptiletracker.ui.MultiPetTimelineScreen
import com.example.reptiletracker.ui.ReptileViewModel
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

                    MultiPetTimelineScreen(
                        petsWithLogs = petsWithLogs,
                        onAddLogClick = { pet -> selectedPetForFeeding = pet },
                        onScheduleClick = { pet ->
                            val nextDueDate = System.currentTimeMillis() + (7 * 24 * 60 * 60 * 1000L)
                            CalendarUtils.addScheduleToGoogleCalendar(
                                context = this@MainActivity,
                                pet = pet,
                                taskName = "Feeding Schedule",
                                dueDateMillis = nextDueDate
                            )
                        }
                    )

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
                }
            }
        }
    }
}
