package com.example.loginscreen
import android.graphics.Color

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.RelativeLayout
import android.widget.SearchView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

class GuestActivity : AppCompatActivity() {

    private lateinit var citySearchText: SearchView
    private lateinit var searchButton: View

    private val API: String = "f01e80368f05c66b03425d3f08ab1a1c" // Use API key

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_guest)

        citySearchText = findViewById(R.id.searchView)
        searchButton = findViewById(R.id.searchButton)

        searchButton.setOnClickListener {
            val cityName = citySearchText.query.toString()
            if (cityName.isNotEmpty()) {
                updateWeather(cityName)
            }
        }

        // Load weather based on default city (aley,lb)
        updateWeather("aley,lb")
    }

    private fun updateWeather(city: String) {
        GlobalScope.launch(Dispatchers.Main) {


            val result = withContext(Dispatchers.IO) {
                try {
                    URL("https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$API")
                        .readText(Charsets.UTF_8)
                } catch (e: Exception) {
                    null
                }
            }

            if (result != null) {
                handleWeatherResponse(result)
            }
        }
    }

    private fun handleWeatherResponse(result: String) {
        try {
            val jsonObj = JSONObject(result)
            val main = jsonObj.getJSONObject("main")
            val sys = jsonObj.getJSONObject("sys")
            val wind = jsonObj.getJSONObject("wind")
            val weather = jsonObj.getJSONArray("weather").getJSONObject(0)

            val updatedAt: Long = jsonObj.getLong("dt")
            val updatedAtText =
                "Updated at: " + SimpleDateFormat("dd/MM/yyyy hh:mm a", Locale.ENGLISH)
                    .format(Date(updatedAt * 1000))

            val weatherDescription = weather.getString("main").toLowerCase(Locale.getDefault())

            val address = jsonObj.getString("name") + ", " + sys.getString("country")
            val temperature = main.getString("temp") // Get the temperature from the API response


            val temperatureTextView = findViewById<TextView>(R.id.temp)
            temperatureTextView.text = "$temperature°C"


            findViewById<TextView>(R.id.address).text = address
            findViewById<TextView>(R.id.updated_at).text = updatedAtText


            updateBackgroundImage(weatherDescription)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private fun updateBackgroundImage(weatherCondition: String) {
        val weatherBackground = findViewById<ImageView>(R.id.weatherBackground)

        val backgroundImageResource = when {
            weatherCondition.contains("clear") -> R.drawable.clear_sky
            weatherCondition.contains("cloud") -> R.drawable.broken_clouds
            weatherCondition.contains("rain") -> R.drawable.rain
            weatherCondition.contains("thunderstorm") -> R.drawable.thunder_storm
            weatherCondition.contains("snow") -> R.drawable.snow
            weatherCondition.contains("mist") || weatherCondition.contains("fog") -> R.drawable.mist
            weatherCondition.contains("windy") || weatherCondition.contains("breezy") -> R.drawable.windy
            weatherCondition.contains("hail") -> R.drawable.hail
            weatherCondition.contains("tornado") -> R.drawable.tornado
            else -> R.drawable.default_weather
        }

        weatherBackground.setImageResource(backgroundImageResource)
    }




}