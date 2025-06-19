package com.example.mediapipe_pose_app

sealed class TargetArea {
    abstract fun contains(x: Float, y: Float): Boolean
    abstract fun toMap(): Map<String, Any>
}

// 🎯 Área circular
data class CircularArea(
    val centerX: Float,
    val centerY: Float,
    val radius: Float
) : TargetArea() {
    override fun contains(x: Float, y: Float): Boolean {
        val dx = x - centerX
        val dy = y - centerY
        return dx * dx + dy * dy <= radius * radius
    }

    override fun toMap(): Map<String, Any> = mapOf(
        "type" to "circle",
        "centerX" to centerX,
        "centerY" to centerY,
        "radius" to radius
    )
}

// 🔲 Área rectangular
data class RectangularArea(
    val left: Float,
    val top: Float,
    val right: Float,
    val bottom: Float
) : TargetArea() {
    override fun contains(x: Float, y: Float): Boolean {
        return x in left..right && y in top..bottom
    }

    override fun toMap(): Map<String, Any> = mapOf(
        "type" to "rectangle",
        "left" to left,
        "top" to top,
        "right" to right,
        "bottom" to bottom
    )
}

class AreaChecker(private val area: TargetArea) {
    fun isInside(x: Float, y: Float): Boolean = area.contains(x, y)
    fun export(): Map<String, Any> = area.toMap()
}
