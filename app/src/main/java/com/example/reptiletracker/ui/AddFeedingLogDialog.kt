package com.example.reptiletracker.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.reptiletracker.data.FeedingReaction

@Composable
fun AddFeedingLogDialog(
    petName: String,
    onDismiss: () -> Unit,
    onSubmit: (foodType: String, weight: Float?, reaction: FeedingReaction, notes: String) -> Unit
) {
    var foodType by remember { mutableStateOf("") }
    var weightText by remember { mutableStateOf("") }
    var selectedReaction by remember { mutableStateOf(FeedingReaction.TAKEN) }
    var notes by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Log Feeding for $petName") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = foodType,
                    onValueChange = { foodType = it },
                    label = { Text("Food Item (e.g. Medium Rat)") }
                )
                OutlinedTextField(
                    value = weightText,
                    onValueChange = { weightText = it },
                    label = { Text("Item Weight (g)") }
                )
                
                Text("Reaction:")
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    FeedingReaction.values().forEach { reaction ->
                        FilterChip(
                            selected = selectedReaction == reaction,
                            onClick = { selectedReaction = reaction },
                            label = { Text(reaction.name) }
                        )
                    }
                }
                
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Notes") }
                )
            }
        },
        confirmButton = {
            Button(onClick = {
                onSubmit(foodType, weightText.toFloatOrNull(), selectedReaction, notes)
            }) {
                Text("Save Log")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

@Composable
fun ScheduleTaskDialog(
    petName: String,
    onDismiss: () -> Unit,
    onSubmit: (taskName: String, daysFromNow: Long, syncWithGoogle: Boolean) -> Unit
) {
    var taskName by remember { mutableStateOf("Scheduled Feeding") }
    var daysText by remember { mutableStateOf("7") }
    var syncWithGoogle by remember { mutableStateOf(true) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Schedule Task for $petName") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = taskName,
                    onValueChange = { taskName = it },
                    label = { Text("Task Name") }
                )
                OutlinedTextField(
                    value = daysText,
                    onValueChange = { daysText = it },
                    label = { Text("Days from today") }
                )
                
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Checkbox(
                        checked = syncWithGoogle,
                        onCheckedChange = { syncWithGoogle = it }
                    )
                    Text("Sync into Google Calendar")
                }
            }
        },
        confirmButton = {
            Button(onClick = {
                val days = daysText.toLongOrNull() ?: 7L
                onSubmit(taskName, days, syncWithGoogle)
            }) {
                Text("Schedule")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}