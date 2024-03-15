import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        const val DATABASE_NAME = "user.db"
        const val DATABASE_VERSION = 2
    }

    override fun onCreate(db: SQLiteDatabase) {
        val SQL_CREATE_ENTRIES =
            "CREATE TABLE ${DatabaseContract.UserEntry.TABLE_NAME} (" +
                    "${DatabaseContract.UserEntry._ID} INTEGER PRIMARY KEY," +
                    "${DatabaseContract.UserEntry.COLUMN_USERNAME} TEXT," +
                    "${DatabaseContract.UserEntry.COLUMN_PASSWORD} TEXT," +
                    "${DatabaseContract.UserEntry.COLUMN_NUM_BATTERIES} INTEGER," +
                    "${DatabaseContract.UserEntry.COLUMN_NUM_SOLAR_PANELS} INTEGER," +
                    "${DatabaseContract.UserEntry.COLUMN_BATTERY_TYPE} TEXT," +
                    "${DatabaseContract.UserEntry.COLUMN_SOLAR_PANEL_TYPE} TEXT)"

        db.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {

        val SQL_DELETE_ENTRIES = "DROP TABLE IF EXISTS ${DatabaseContract.UserEntry.TABLE_NAME}"
        db.execSQL(SQL_DELETE_ENTRIES)
        onCreate(db)
    }
    fun userExists(username: String, password: String): Boolean {
        val db = this.readableDatabase

        val selection = "${DatabaseContract.UserEntry.COLUMN_USERNAME} = ? AND " +
                "${DatabaseContract.UserEntry.COLUMN_PASSWORD} = ?"
        val selectionArgs = arrayOf(username, password)

        val cursor = db.query(
            DatabaseContract.UserEntry.TABLE_NAME,
            null, // Projection (null means all columns)
            selection,
            selectionArgs,
            null,
            null,
            null
        )

        val userExists = cursor.moveToFirst()
        cursor.close()

        return userExists
    }
    fun isUserAlreadyRegistered(username: String): Boolean {
        val db = readableDatabase
        val projection = arrayOf(DatabaseContract.UserEntry.COLUMN_USERNAME)
        val selection = "${DatabaseContract.UserEntry.COLUMN_USERNAME} = ?"
        val selectionArgs = arrayOf(username)

        val cursor = db.query(
            DatabaseContract.UserEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        )

        val userExists = cursor.count > 0
        cursor.close()
        return userExists
    }
    fun getUserDetails(username: String?): Cursor? {
        val db = readableDatabase
        val projection = arrayOf(
            DatabaseContract.UserEntry.COLUMN_NUM_BATTERIES,
            DatabaseContract.UserEntry.COLUMN_NUM_SOLAR_PANELS,
            DatabaseContract.UserEntry.COLUMN_BATTERY_TYPE,
            DatabaseContract.UserEntry.COLUMN_SOLAR_PANEL_TYPE
        )
        val selection = "${DatabaseContract.UserEntry.COLUMN_USERNAME} = ?"
        val selectionArgs = arrayOf(username)

        return db.query(
            DatabaseContract.UserEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        )
    }

}
