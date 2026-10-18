package com.example.reptiletracker.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.example.reptiletracker.data.LogEntry

@Composable
fun WeightGrowthChart(
    weightLogs: List<LogEntry>,
    modifier: Modifier = Modifier.fillMaxWidth().height(200.dp)
) {
    if (weightLogs.size < 2) {
        Box(modifier = modifier, contentAlignment = androidx.compose.ui.Alignment.Center) {
            Text("Log at least 2 weigh-ins to render growth chart.")
        }
        return
    }

    val lineColor = MaterialTheme.colorScheme.primary

    Canvas(modifier = modifier) {
        val points = listOf(Offset(50f, size.height - 50f), Offset(size.width - 50f, 50f))
        val path = Path().apply {
            moveTo(points[0].x, points[0].y)
            lineTo(points[1].x, points[1].y)
        }
        drawPath(path, color = lineColor, style = Stroke(width = 4.dp.toPx(), cap = StrokeCap.Round))
    }
}