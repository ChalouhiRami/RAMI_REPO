package com.example.loginscreen

import DatabaseHelper

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

class LoginActivity : AppCompatActivity() {

    private lateinit var username: EditText
    private lateinit var password: EditText
    private lateinit var loginButton: Button
    private lateinit var signupText: Button
    private lateinit var continueAsGuestButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        username = findViewById(R.id.username)
        password = findViewById(R.id.password)
        loginButton = findViewById(R.id.loginButton)
        signupText = findViewById(R.id.signupText)
        continueAsGuestButton = findViewById(R.id.continueAsGuestButton)

        loginButton.setOnClickListener {
            val enteredUsername = username.text.toString()
            val enteredPassword = password.text.toString()

            val dbHelper = DatabaseHelper(this@LoginActivity)

            if (dbHelper.userExists(enteredUsername, enteredPassword)) {

                Toast.makeText(this@LoginActivity, "Login Successful!", Toast.LENGTH_SHORT).show()
                val weatherIntent = Intent(this@LoginActivity, WeatherActivity::class.java)
                weatherIntent.putExtra("loggedInUsername", enteredUsername)
                startActivity(weatherIntent)
                finish()



            } else {

                Toast.makeText(this@LoginActivity, "Login Failed!", Toast.LENGTH_SHORT).show()
            }
        }


        signupText.setOnClickListener {

            val intent = Intent(this@LoginActivity, RegisterActivity::class.java)
            startActivity(intent)
            finish()
       }
        continueAsGuestButton.setOnClickListener {

            val intent = Intent(this@LoginActivity, GuestActivity::class.java)


            startActivity(intent)
            finish()
        }
    }
}
