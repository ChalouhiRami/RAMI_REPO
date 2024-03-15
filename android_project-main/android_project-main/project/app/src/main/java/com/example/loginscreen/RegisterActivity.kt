package com.example.loginscreen



import DatabaseHelper
import android.content.ContentValues
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class RegisterActivity : AppCompatActivity() {

    private lateinit var registerUsername: EditText
    private lateinit var registerPassword: EditText
    private lateinit var confirmPassword: EditText
    private lateinit var registerButton: Button
    private lateinit var loginText: TextView
    private lateinit var registerNumBatteries: EditText
    private lateinit var registerNumSolarPanels: EditText
    private lateinit var registerBatteryType: EditText
    private lateinit var registerSolarPanelType: EditText
    private lateinit var dbHelper: DatabaseHelper

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        dbHelper = DatabaseHelper(this)

        registerUsername = findViewById(R.id.registerUsername)
        registerPassword = findViewById(R.id.registerPassword)
        confirmPassword = findViewById(R.id.confirmPassword)
        registerNumBatteries = findViewById(R.id.registerNumBatteries)
        registerNumSolarPanels = findViewById(R.id.registerNumSolarPanels)
        registerBatteryType = findViewById(R.id.registerBatteryType)
        registerSolarPanelType = findViewById(R.id.registerSolarPanelType)
        registerButton = findViewById(R.id.registerButton)
        loginText = findViewById(R.id.loginText)

        registerButton.setOnClickListener { registerUser() }

        loginText.setOnClickListener {
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
            finish()
        }
    }

    private fun registerUser() {
        val username = registerUsername.text.toString().trim()
        val password = registerPassword.text.toString().trim()
        val confirmPass = confirmPassword.text.toString().trim()
        val numBatteries = registerNumBatteries.text.toString().toIntOrNull() ?: 0
        val numSolarPanels = registerNumSolarPanels.text.toString().toIntOrNull() ?: 0
        val batteryType = registerBatteryType.text.toString().trim()
        val solarPanelType = registerSolarPanelType.text.toString().trim()

        if (username.isEmpty() || password.isEmpty() || confirmPass.isEmpty()) {
            showToast("Please fill in all fields.")
            return
        }

        if (password != confirmPass) {
            showToast("Passwords do not match.")
        } else {
            if (dbHelper.isUserAlreadyRegistered(username)) {
                showToast("Username already exists. Please choose another username.")
            } else {
                // Insert user data into the database
                val db = dbHelper.writableDatabase
                val values = ContentValues()
                values.put(DatabaseContract.UserEntry.COLUMN_USERNAME, username)
                values.put(DatabaseContract.UserEntry.COLUMN_PASSWORD, password)
                values.put(DatabaseContract.UserEntry.COLUMN_NUM_BATTERIES, numBatteries)
                values.put(DatabaseContract.UserEntry.COLUMN_NUM_SOLAR_PANELS, numSolarPanels)
                values.put(DatabaseContract.UserEntry.COLUMN_BATTERY_TYPE, batteryType)
                values.put(DatabaseContract.UserEntry.COLUMN_SOLAR_PANEL_TYPE, solarPanelType)

                val newRowId = db.insert(DatabaseContract.UserEntry.TABLE_NAME, null, values)

                if (newRowId != -1L) {
                    showToast("Registration successful. Redirecting to login.")

                    val intent = Intent(this, LoginActivity::class.java)
                    startActivity(intent)
                    finish()
                } else {
                    showToast("Error during registration. Please try again.")
                }
            }
        }
    }



    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}
