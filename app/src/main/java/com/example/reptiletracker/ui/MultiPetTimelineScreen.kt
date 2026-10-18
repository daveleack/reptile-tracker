package com.example.reptiletracker.ui

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.reptiletracker.data.*
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MultiPetTimelineScreen(
    petsWithLogs: Map<Pet, List<LogEntry>>,
    onAddPetClick: () -> Unit,
    onRenamePetClick: (Pet) -> Unit,
    onAddLogClick: (Pet) -> Unit,
    onScheduleClick: (Pet) -> Unit
) {
    val horizontalScrollState = rememberScrollState()
    
    val days = remember {
        (0..13).map { daysAgo ->
            Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, -daysAgo)
            }.time
        }.reversed()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Reptile Health Matrix") },
                actions = {
                    Button(
                        onClick = onAddPetClick,
                        modifier = Modifier.padding(end = 8.dp)
                    ) {
                        Text("+ Add Pet")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            Row(modifier = Modifier.fillMaxWidth().background(MaterialTheme.colorScheme.surfaceVariant)) {
                Box(
                    modifier = Modifier.width(130.dp).padding(12.dp),
                    contentAlignment = Alignment.CenterStart
                ) {
                    Text("Reptile", fontWeight = FontWeight.Bold)
                }

                Row(
                    modifier = Modifier
                        .horizontalScroll(horizontalScrollState)
                        .padding(vertical = 8.dp)
                ) {
                    days.forEach { date ->
                        val dayFormat = SimpleDateFormat("EEE\nd/M", Locale.getDefault())
                        Box(
                            modifier = Modifier.width(70.dp).padding(horizontal = 4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = dayFormat.format(date),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }
                }
            }

            Divider()

            LazyColumn(modifier = Modifier.fillMaxSize()) {
                items(petsWithLogs.keys.toList()) { pet ->
                    PetTimelineRow(
                        pet = pet,
                        logs = petsWithLogs[pet] ?: emptyList(),
                        days = days,
                        horizontalScrollState = horizontalScrollState,
                        onRenamePet = { onRenamePetClick(pet) },
                        onAddLog = { onAddLogClick(pet) },
                        onSchedule = { onScheduleClick(pet) }
                    )
                    Divider()
                }
            }
        }
    }
}

@Composable
fun PetTimelineRow(
    pet: Pet,
    logs: List<LogEntry>,
    days: List<Date>,
    horizontalScrollState: ScrollState,
    onRenamePet: () -> Unit,
    onAddLog: () -> Unit,
    onSchedule: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth().height(96.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            modifier = Modifier
                .width(130.dp)
                .fillMaxHeight()
                .padding(6.dp),
            verticalArrangement = Arrangement.Center
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = pet.name,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    modifier = Modifier.clickable { onRenamePet() }
                )
                Text(
                    text = "âœï¸",
                    fontSize = 10.sp,
                    modifier = Modifier.clickable { onRenamePet() }
                )
            }
            Text(pet.species, fontSize = 11.sp, color = Color.Gray)
            
            Row(
                horizontalArrangement = Arrangement.spacedBy(2.dp),
                modifier = Modifier.padding(top = 4.dp)
            ) {
                AssistChip(
                    onClick = onAddLog,
                    label = { Text("+ Log", fontSize = 9.sp) },
                    modifier = Modifier.height(22.dp)
                )
                AssistChip(
                    onClick = onSchedule,
                    label = { Text("ðŸ“…", fontSize = 9.sp) },
                    modifier = Modifier.height(22.dp)
                )
            }
        }

        Divider(modifier = Modifier.fillMaxHeight().width(1.dp))

        Row(
            modifier = Modifier.horizontalScroll(horizontalScrollState).fillMaxHeight(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            val dateFormat = SimpleDateFormat("yyyyMMdd", Locale.getDefault())

            days.forEach { date ->
                val dateStr = dateFormat.format(date)
                val dayLogs = logs.filter { dateFormat.format(Date(it.timestamp)) == dateStr }

                Box(
                    modifier = Modifier
                        .width(70.dp)
                        .fillMaxHeight()
                        .border(0.5.dp, Color.LightGray.copy(alpha = 0.5f))
                        .padding(2.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        verticalArrangement = Arrangement.spacedBy(2.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        dayLogs.forEach { log ->
                            LogChip(log = log)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun LogChip(log: LogEntry) {
    val (bgColor, label) = when (log.type) {
        LogType.FEEDING -> {
            val color = when (log.feedingReaction) {
                FeedingReaction.TAKEN -> Color(0xFF4CAF50)
                FeedingReaction.REFUSED -> Color(0xFFE53935)
                FeedingReaction.TAKEN_LATE -> Color(0xFFFFB300)
                null -> Color.Gray
            }
            color to "ðŸ½ï¸ ${log.foodType ?: ""}"
        }
        LogType.WEIGHING -> Color(0xFF2196F3) to "âš–ï¸ ${log.weightGrams?.toInt()}g"
        LogType.SHEDDING -> Color(0xFF9C27B0) to "ðŸ Shed"
        LogType.CLEANING -> Color(0xFF00BCD4) to "ðŸ§¹ Clean"
        LogType.NOTE -> Color(0xFF607D8B) to "ðŸ“ Note"
    }

    Surface(
        color = bgColor,
        shape = RoundedCornerShape(4.dp),
        modifier = Modifier.padding(1.dp)
    ) {
        Text(
            text = label,
            color = Color.White,
            fontSize = 9.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
        )
    }
}