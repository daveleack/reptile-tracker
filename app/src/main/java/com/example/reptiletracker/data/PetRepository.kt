package com.example.reptiletracker.data

import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PetRepository @Inject constructor(
    private val petDao: PetDao
) {
    val allPets: Flow<List<Pet>> = petDao.getAllPets()
    val allLogs: Flow<List<LogEntry>> = petDao.getAllLogs()

    fun getLogsForPet(petId: Long): Flow<List<LogEntry>> = petDao.getLogsForPet(petId)

    suspend fun addPet(pet: Pet) = petDao.insertPet(pet)
    suspend fun addLog(logEntry: LogEntry) = petDao.insertLogEntry(logEntry)
    suspend fun deletePet(pet: Pet) = petDao.deletePet(pet)
}
