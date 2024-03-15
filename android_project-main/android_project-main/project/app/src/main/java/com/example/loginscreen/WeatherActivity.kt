package com.example.loginscreen
import DatabaseHelper
import android.content.Intent
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

class WeatherActivity : AppCompatActivity() {

    private lateinit var citySearchText: SearchView
    private lateinit var searchButton: View
    private lateinit var dbHelper: DatabaseHelper

    private val API: String = "f01e80368f05c66b03425d3f08ab1a1c"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_weather)
        dbHelper = DatabaseHelper(this)
        citySearchText = findViewById(R.id.searchView)
        searchButton = findViewById(R.id.searchButton)

        searchButton.setOnClickListener {
            val cityName = citySearchText.query.toString()
            if (cityName.isNotEmpty()) {
                updateWeather(cityName)
            }
        }
        val aboutTextView: TextView = findViewById(R.id.about)
        aboutTextView.setOnClickListener {

            val loginIntent = Intent(this@WeatherActivity, LoginActivity::class.java)
            startActivity(loginIntent)


            finish()
        }

        updateWeather("aley,lb")
    }

    private fun updateWeather(city: String) {
        GlobalScope.launch(Dispatchers.Main) {
            showLoading()

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
            } else {
                showError()
            }
        }
    }
    private fun setTextColorBasedOnCondition(textView: TextView, weatherCondition: String) {
        when {
            weatherCondition.contains("clear") -> {
                textView.setTextColor(Color.BLACK)
            }
            weatherCondition.contains("cloud") -> {
                textView.setTextColor(Color.WHITE)
            }
            weatherCondition.contains("rain") -> {
                textView.setTextColor(Color.BLACK)
            }
            weatherCondition.contains("thunderstorm") -> {
                textView.setTextColor(Color.WHITE)
            }
            weatherCondition.contains("snow") -> {
                textView.setTextColor(Color.BLACK)
            }
            weatherCondition.contains("mist") || weatherCondition.contains("fog") -> {
                textView.setTextColor(Color.WHITE)
            }
            weatherCondition.contains("windy") || weatherCondition.contains("breezy") -> {
                textView.setTextColor(Color.BLACK)
            }
            else -> {

                textView.setTextColor(Color.WHITE)
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
            val tempMin = "Min Temp: " + main.getString("temp_min") + "°C"
            val tempMax = "Max Temp: " + main.getString("temp_max") + "°C"

            val sunrise: Long = sys.getLong("sunrise")
            val sunset: Long = sys.getLong("sunset")
            val windSpeed = wind.getString("speed")
            val weatherDescription = weather.getString("main").toLowerCase(Locale.getDefault())

            val address = jsonObj.getString("name") + ", " + sys.getString("country")

            val temperature = main.getString("temp") // Get the temperature from the API response


            val temperatureTextView = findViewById<TextView>(R.id.temp)
            temperatureTextView.text = "$temperature°C"
            findViewById<TextView>(R.id.address).text = address
            findViewById<TextView>(R.id.updated_at).text = updatedAtText


            val statusTextView = findViewById<TextView>(R.id.status)
            statusTextView.text = weatherDescription.capitalize()
            setTextColorBasedOnCondition(statusTextView, weatherDescription)


            val tempMinTextView = findViewById<TextView>(R.id.temp_min)
            setTextColorBasedOnCondition(tempMinTextView, weatherDescription)
            tempMinTextView.text = tempMin


            val tempMaxTextView = findViewById<TextView>(R.id.temp_max)
            setTextColorBasedOnCondition(tempMaxTextView, weatherDescription)
            tempMaxTextView.text = tempMax

            updateBackgroundImage(weatherDescription)
            showRecommendation(weatherDescription)
            showSolarPanelInfo(weatherDescription)

            hideLoading()

        } catch (e: Exception) {
            showError()
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

    private fun showRecommendation(weatherCondition: String) {
        val recommendationText = findViewById<TextView>(R.id.weatherRecommendation)

        val recommendation = when {
            weatherCondition.contains("clear") -> "It's a clear sky! Consider going for a picnic or outdoor activities."
            weatherCondition.contains("cloud") -> "Cloudy weather! Perfect for a cozy day at home or visiting a museum."
            weatherCondition.contains("rain") -> "Rainy day! don't forget to carry a umbrella!"
            weatherCondition.contains("thunderstorm") -> "Thunderstorm! Stay indoors and enjoy a movie or play board games."
            weatherCondition.contains("snow") -> "Snowy conditions! Have fun building a snowman or skiing if possible."
            weatherCondition.contains("mist") || weatherCondition.contains("fog") ->
                "Misty or foggy weather! Consider a peaceful walk in a park or garden."
            weatherCondition.contains("windy") || weatherCondition.contains("breezy") ->
                "Windy weather! A great time to fly  a drone."


            else -> "Default recommendation for other weather conditions."
        }
        setTextColorBasedOnCondition(recommendationText, weatherCondition)
        recommendationText.text = recommendation

    }

    private fun showSolarPanelInfo(weatherCondition: String) {
        val loggedInUsername = intent.getStringExtra("loggedInUsername")
        val userCursor = dbHelper.getUserDetails(loggedInUsername)

        var numberOfBatteries = 0
        var numberOfSolarPanels = 0
        var batteryType = ""
        var solarPanelType = ""

        if (userCursor != null && userCursor.moveToFirst()) {
            val numBatteriesIndex = userCursor.getColumnIndex(DatabaseContract.UserEntry.COLUMN_NUM_BATTERIES)
            val numSolarPanelsIndex = userCursor.getColumnIndex(DatabaseContract.UserEntry.COLUMN_NUM_SOLAR_PANELS)
            val batteryTypeIndex = userCursor.getColumnIndex(DatabaseContract.UserEntry.COLUMN_BATTERY_TYPE)
            val solarPanelTypeIndex = userCursor.getColumnIndex(DatabaseContract.UserEntry.COLUMN_SOLAR_PANEL_TYPE)

            if (numBatteriesIndex != -1) numberOfBatteries = userCursor.getInt(numBatteriesIndex)
            if (numSolarPanelsIndex != -1) numberOfSolarPanels = userCursor.getInt(numSolarPanelsIndex)
            if (batteryTypeIndex != -1) batteryType = userCursor.getString(batteryTypeIndex)
            if (solarPanelTypeIndex != -1) solarPanelType = userCursor.getString(solarPanelTypeIndex)

            userCursor.close()
        }
        val solarPanelMessage = findViewById<TextView>(R.id.solarPanelMessage)

        val solarMessage : Any = when {
            numberOfSolarPanels == null || numberOfSolarPanels <= 0 ->
                solarPanelMessage.visibility = View.INVISIBLE
            numberOfBatteries >= 2 && numberOfSolarPanels >= 3 && weatherCondition.contains("clear") ->
                "You have a high number of batteries and solar panels. It's a great time for solar panel charging."


            numberOfBatteries == 1 && weatherCondition.contains("clear") ->
                "Considering you have only one battery and it's a clear day, consider saving it and using electricity efficiently."

            numberOfBatteries < 2 && numberOfSolarPanels < 2 && weatherCondition.contains("cloud") ->
                "Consider additional charging options as you have a low number of batteries and solar panels, and it's cloudy."
            numberOfBatteries >= 2 && numberOfSolarPanels >= 2 && weatherCondition.contains("cloud") ->
                "You have a sufficient number of batteries and solar panels, but make sure to monitor your energy usage efficiently since it is cloudy."


            batteryType.equals("lithium", ignoreCase = true) && weatherCondition.contains("rain") ->
                "Lithium batteries are resilient, but consider covering them during rain for optimal performance."

            solarPanelType.equals(
                "monocrystalline",
                ignoreCase = true
            ) && weatherCondition.contains("snow") ->
                "Clear snow off your monocrystalline solar panels for better efficiency."

            numberOfBatteries > 10 && weatherCondition.contains("thunderstorm") ->
                "You have a large number of batteries. It's advisable to disconnect them during a thunderstorm."

            numberOfBatteries > 3 && weatherCondition.contains("mist") ->
                "You have a moderate number of batteries. Solar panels may be less effective in misty conditions."

            numberOfSolarPanels > 5 && weatherCondition.contains("windy") ->
                "You have a high number of solar panels. Secure them properly in windy conditions."



            batteryType.equals(
                "lead-acid",
                ignoreCase = true
            ) && weatherCondition.contains("hail") ->
                "Protect lead-acid batteries from hail to avoid damage."

            numberOfBatteries > 7 && solarPanelType.equals(
                "polycrystalline",
                ignoreCase = true
            ) && weatherCondition.contains("tornado") ->
                "You have a significant number of batteries and polycrystalline solar panels. Take precautions to secure them during a tornado."

            else -> "Make sure your solar panels are well protected!."
        }
        setTextColorBasedOnCondition(solarPanelMessage, weatherCondition)
        solarPanelMessage.text = solarMessage.toString()
    }

    private fun showError() {
        findViewById<ProgressBar>(R.id.loader).visibility = View.GONE
        findViewById<TextView>(R.id.errorText).visibility = View.VISIBLE
    }

    private fun showLoading() {
        findViewById<ProgressBar>(R.id.loader).visibility = View.VISIBLE
        findViewById<RelativeLayout>(R.id.mainContainer).visibility = View.GONE
        findViewById<TextView>(R.id.errorText).visibility = View.GONE
    }

    private fun hideLoading() {
        findViewById<ProgressBar>(R.id.loader).visibility = View.GONE
        findViewById<RelativeLayout>(R.id.mainContainer).visibility = View.VISIBLE
    }
}
