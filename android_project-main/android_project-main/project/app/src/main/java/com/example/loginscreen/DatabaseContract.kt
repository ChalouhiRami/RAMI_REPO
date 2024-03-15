import android.provider.BaseColumns

object DatabaseContract {

    object UserEntry : BaseColumns {
        const val _ID = BaseColumns._ID
        const val TABLE_NAME = "users"
        const val COLUMN_USERNAME = "username"
        const val COLUMN_PASSWORD = "password"
        const val COLUMN_NUM_BATTERIES = "num_batteries"
        const val COLUMN_NUM_SOLAR_PANELS = "num_solar_panels"
        const val COLUMN_BATTERY_TYPE = "battery_type"
        const val COLUMN_SOLAR_PANEL_TYPE = "solar_panel_type"
    }

}
