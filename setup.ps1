# setup.ps1 - Generates the complete Reptile Tracker repository layout & source files

Write-Host "Creating folder structure..." -ForegroundColor Green

# 1. Create Directories
$dirs = @(
    ".github\workflows",
    "gradle\wrapper",
    "app\src\main\res\values",
    "app\src\main\java\com\example\reptiletracker",
    "app\src\main\java\com\example\reptiletracker\data",
    "app\src\main\java\com\example\reptiletracker\di",
    "app\src\main\java\com\example\reptiletracker\ui",
    "app\src\main\java\com\example\reptiletracker\ui\components",
    "app\src\main\java\com\example\reptiletracker\util",
    "app\src\main\java\com\example\reptiletracker\worker"
)

foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}

Write-Host "Writing project files..." -ForegroundColor Green

# --- 2. ROOT CONFIGURATION FILES ---

$buildApkYaml = @"
name: Build Android APK

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Gradle 8.4
        uses: gradle/actions/setup-gradle@v3
        with:
          gradle-version: '8.4'

      - name: Build Debug APK
        run: gradle assembleDebug --stacktrace

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ReptileTracker-Debug-APK
          path: app/build/outputs/apk/debug/app-debug.apk
"@
Set-Content -Path ".github\workflows\build-apk.yml" -Value $buildApkYaml -Encoding UTF8

$settingsGradle = @"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ReptileTracker"
include(":app")
"@
Set-Content -Path "settings.gradle.kts" -Value $settingsGradle -Encoding UTF8

$buildGradleRoot = @"
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.hilt.android) apply false
}
"@
Set-Content -Path "build.gradle.kts" -Value $buildGradleRoot -Encoding UTF8

$gradleProperties = @"
android.useAndroidX=true
android.nonTransitiveRClass=true
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
kotlin.code.style=official
"@
Set-Content -Path "gradle.properties" -Value $gradleProperties -Encoding UTF8

$libsVersionsToml = @"
[versions]
agp = "8.2.2"
kotlin = "1.9.22"
coreKtx = "1.12.0"
lifecycleRuntimeKtx = "2.7.0"
activityCompose = "1.8.2"
composeBom = "2024.02.00"
room = "2.6.1"
hilt = "2.50"
work = "2.9.0"

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
androidx-lifecycle-runtime-ktx = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycleRuntimeKtx" }
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
androidx-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
androidx-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-material3 = { group = "androidx.compose.material3", name = "material3" }

androidx-room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
androidx-room-compiler = { group = "androidx.room", name = "room-compiler", version.ref = "room" }
androidx-room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }

hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-compiler", version.ref = "hilt" }

androidx-work-runtime-ktx = { group = "androidx.work", name = "work-runtime-ktx", version.ref = "work" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
hilt-android = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
"@
Set-Content -Path "gradle\libs.versions.toml" -Value $libsVersionsToml -Encoding UTF8

# --- 3. APP MODULE CONFIGURATION ---

$appBuildGradle = @"
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.hilt.android)
    kotlin("kapt")
}

android {
    namespace = "com.example.reptiletracker"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.reptiletracker"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        vectorDrawables { useSupportLibrary = true }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.8" }
    packaging { resources { excludes += "/META-INDEX/{AL2.0,LGPL2.1}" } }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)

    implementation(libs.androidx.room.runtime)
    implementation(libs.androidx.room.ktx)
    kapt(libs.androidx.room.compiler)

    implementation(libs.hilt.android)
    kapt(libs.hilt.compiler)

    implementation(libs.androidx.work.runtime.ktx)
}
"@
Set-Content -Path "app\build.gradle.kts" -Value $appBuildGradle -Encoding UTF8

$androidManifest = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:name=".ReptileApplication"
        android:allowBackup="true"
        android:label="Reptile Tracker"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:label="Reptile Tracker"
            android:theme="@android:style/Theme.Material.Light.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>

</manifest>
"@
Set-Content -Path "app\src\main\AndroidManifest.xml" -Value $androidManifest -Encoding UTF8

# --- 4. APP SOURCE CODE (.kt) ---

$reptileApp = @"
package com.example.reptiletracker

import android.app.Application
import com.example.reptiletracker.util.NotificationHelper
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class ReptileApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        NotificationHelper.createNotificationChannel(this)
    }
}
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\ReptileApplication.kt" -Value $reptileApp -Encoding UTF8

$mainActivity = @"
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\MainActivity.kt" -Value $mainActivity -Encoding UTF8

$petData = @"
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\data\PetData.kt" -Value $petData -Encoding UTF8

$petDao = @"
package com.example.reptiletracker.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface PetDao {
    @Query("SELECT * FROM pets ORDER BY name ASC")
    fun getAllPets(): Flow<List<Pet>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertPet(pet: Pet)

    @Delete
    suspend fun deletePet(pet: Pet)

    @Query("SELECT * FROM log_entries WHERE petId = :petId ORDER BY timestamp DESC")
    fun getLogsForPet(petId: Long): Flow<List<LogEntry>>

    @Query("SELECT * FROM log_entries ORDER BY timestamp DESC")
    fun getAllLogs(): Flow<List<LogEntry>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLogEntry(logEntry: LogEntry)

    @Delete
    suspend fun deleteLogEntry(logEntry: LogEntry)
}
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\data\PetDao.kt" -Value $petDao -Encoding UTF8

$appDatabase = @"
package com.example.reptiletracker.data

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [Pet::class, LogEntry::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun petDao(): PetDao
}
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\data\AppDatabase.kt" -Value $appDatabase -Encoding UTF8

$petRepository = @"
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\data\PetRepository.kt" -Value $petRepository -Encoding UTF8

$databaseModule = @"
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\di\DatabaseModule.kt" -Value $databaseModule -Encoding UTF8

$multiPetTimelineScreen = @"
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
        topBar = { TopAppBar(title = { Text("Reptile Health Matrix") }) }
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
                        onAddLog = { onAddLogClick(pet) }
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
    onAddLog: () -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth().height(88.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            modifier = Modifier
                .width(130.dp)
                .fillMaxHeight()
                .padding(8.dp),
            verticalArrangement = Arrangement.Center
        ) {
            Text(pet.name, fontWeight = FontWeight.Bold, fontSize = 15.sp)
            Text(pet.species, fontSize = 11.sp, color = Color.Gray)
            AssistChip(
                onClick = onAddLog,
                label = { Text("+ Log", fontSize = 10.sp) },
                modifier = Modifier.height(24.dp)
            )
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
            color to "🍽️ ${log.foodType ?: ""}"
        }
        LogType.WEIGHING -> Color(0xFF2196F3) to "⚖️ ${log.weightGrams?.toInt()}g"
        LogType.SHEDDING -> Color(0xFF9C27B0) to "🐍 Shed"
        LogType.CLEANING -> Color(0xFF00BCD4) to "🧹 Clean"
        LogType.NOTE -> Color(0xFF607D8B) to "📝 Note"
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\ui\MultiPetTimelineScreen.kt" -Value $multiPetTimelineScreen -Encoding UTF8

$addFeedingLogDialog = @"
package com.example.reptiletracker.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\ui\AddFeedingLogDialog.kt" -Value $addFeedingLogDialog -Encoding UTF8

$reptileViewModel = @"
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
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\ui\ReptileViewModel.kt" -Value $reptileViewModel -Encoding UTF8

$calendarUtils = @"
package com.example.reptiletracker.util

import android.content.Context
import android.content.Intent
import android.provider.CalendarContract
import com.example.reptiletracker.data.Pet

object CalendarUtils {
    fun addScheduleToGoogleCalendar(
        context: Context,
        pet: Pet,
        taskName: String,
        dueDateMillis: Long
    ) {
        val intent = Intent(Intent.ACTION_INSERT).apply {
            data = CalendarContract.Events.CONTENT_URI
            putExtra(CalendarContract.Events.TITLE, "${pet.name}: $taskName")
            putExtra(CalendarContract.Events.DESCRIPTION, "Reptile maintenance task for ${pet.species}")
            putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, dueDateMillis)
            putExtra(CalendarContract.EXTRA_EVENT_END_TIME, dueDateMillis + (30 * 60 * 1000))
        }
        context.startActivity(intent)
    }
}
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\util\CalendarUtils.kt" -Value $calendarUtils -Encoding UTF8

$notificationHelper = @"
package com.example.reptiletracker.util

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationHelper {
    const val CHANNEL_ID = "reptile_reminders_channel"

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Reptile Reminders",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
"@
Set-Content -Path "app\src\main\java\com\example\reptiletracker\util\NotificationHelper.kt" -Value $notificationHelper -Encoding UTF8

Write-Host "Done! Project structure and source files created successfully." -ForegroundColor Cyan