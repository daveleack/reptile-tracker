package com.example.reptiletracker.data

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [Pet::class, LogEntry::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun petDao(): PetDao
}
