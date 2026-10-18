package com.example.reptiletracker.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.reptiletracker.data.Pet

@Composable
fun AddPetDialog(
    onDismiss: () -> Unit,
    onSubmit: (name: String, species: String) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var species by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add New Reptile") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Pet Name") }
                )
                OutlinedTextField(
                    value = species,
                    onValueChange = { species = it },
                    label = { Text("Species (e.g., Ball Python)") }
                )
            }
        },
        confirmButton = {
            Button(
                enabled = name.isNotBlank() && species.isNotBlank(),
                onClick = { onSubmit(name, species) }
            ) {
                Text("Add Pet")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

@Composable
fun RenamePetDialog(
    pet: Pet,
    onDismiss: () -> Unit,
    onSubmit: (newName: String) -> Unit
) {
    var newName by remember { mutableStateOf(pet.name) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Rename ${pet.name}") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = newName,
                    onValueChange = { newName = it },
                    label = { Text("New Name") }
                )
            }
        },
        confirmButton = {
            Button(
                enabled = newName.isNotBlank(),
                onClick = { onSubmit(newName) }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}