package com.example.reptiletracker.di

import android.content.Context
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.reptiletracker.data.AppDatabase
import com.example.reptiletracker.data.Pet
import com.example.reptiletracker.data.PetDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Provider
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideAppDatabase(
        @ApplicationContext context: Context,
        petDaoProvider: Provider<PetDao>
    ): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "reptile_tracker_db"
        )
        .addCallback(object : RoomDatabase.Callback() {
            override fun onCreate(db: SupportSQLiteDatabase) {
                super.onCreate(db)
                CoroutineScope(Dispatchers.IO).launch {
                    val dao = petDaoProvider.get()
                    dao.insertPet(Pet(name = "Monty", species = "Ball Python"))
                    dao.insertPet(Pet(name = "Ziggy", species = "Bearded Dragon"))
                }
            }
        })
        .build()
    }

    @Provides
    fun providePetDao(database: AppDatabase): PetDao {
        return database.petDao()
    }
}