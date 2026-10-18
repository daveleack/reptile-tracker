package com.example.reptiletracker.data

import androidx.room.*

enum class LogType { FEEDING, WEIGHING, SHEDDING, CLEANING, NOTE }
enum class FeedingReaction { TAKEN, REFUSED, TAKEN_LATE }

@Entity(tableName = "pets")
data class Pet(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val species: String,
    val photoUri: String? = null
)

@Entity(
    tableName = "log_entries",
    foreignKeys = [
        ForeignKey(
            entity = Pet::class,
            parentColumns = ["id"],
            childColumns = ["petId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("petId")]
)
data class LogEntry(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val petId: Long,
    val timestamp: Long,
    val type: LogType,
    val foodType: String? = null,
    val weightGrams: Float? = null,
    val feedingReaction: FeedingReaction? = null,
    val photoUri: String? = null,
    val notes: String? = null
)
