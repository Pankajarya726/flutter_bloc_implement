package com.test_tekit_solution

import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.media.RingtoneManager
import android.os.*
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.common.api.ResultCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.LocationSettingsStatusCodes
import com.test_tekit_solution.Constant.ACTION.Companion.destinationLat
import com.test_tekit_solution.Constant.ACTION.Companion.destinationLong
import java.util.*

class UpdateLocationService : Service(), GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener, com.google.android.gms.location.LocationListener {


    private val TAG = UpdateLocationService::class.java.simpleName
    private val NOTIFICATION_ID = 12345678
    var FOREGROUND_SERVICE = 101
    var notificationID = 5555
    var alert = 6666
    var location: Location? = null
    var timer: Timer? = null

    private var mGoogleApiClient: GoogleApiClient? = null
    private var mContext: Context? = null
    private var locationRequest: LocationRequest? = null
    private var timerTask: TimerTask? = null
    var manager: LocationManager? = null
    override fun onBind(arg0: Intent): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        mGoogleApiClient = GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build()
        mGoogleApiClient!!.connect()
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        if (intent.action == Constant.ACTION.STARTFOREGROUND_ACTION) {
            Log.e(TAG, "Received Start Foreground Intent")
            mContext = applicationContext
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                showGpsOnAlert()
            }
            manager = applicationContext.getSystemService(LOCATION_SERVICE) as LocationManager
            manager!!.requestLocationUpdates(LocationManager.GPS_PROVIDER, 50000, 30f, object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    Log.e("Location Changed to :", "Lattitude is -" + location.latitude + "\t Longitude is -" + location.longitude)

//                    checkForNotification();
                }

                override fun onStatusChanged(s: String, i: Int, bundle: Bundle) {
                    Log.e(TAG, s + "onStatusChanged " + i)
                }

                override fun onProviderEnabled(s: String) {
                    Log.e(TAG, "onStatusChanged $s")
                    val manager = mContext!!.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                    manager.cancel(alert)
                }

                override fun onProviderDisabled(s: String) {
                    Log.e(TAG, "onStatusChanged $s")
                    showGpsOnAlert()
                }
            })
            locationRequest = LocationRequest.create()
            locationRequest!!.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
            locationRequest!!.setInterval(10000)
            locationRequest!!.setFastestInterval(5000)


            val handler = Handler {
                getLocation()
                true
            }
            timer = Timer()
            timerTask = object : TimerTask() {
                override fun run() {
                    object : Thread() {
                        override fun run() {
                            val msg = Message()
                            handler.sendMessage(msg)
                        }
                    }.start()
                }
            }
            timer!!.schedule(timerTask, 0, 15000)
        } else if (intent.action == Constant.ACTION.STOPFOREGROUND_ACTION) {
            Log.e(TAG, "Received Stop Foreground Intent")
            timer!!.cancel()
            stopForeground(true)
            stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun getLocation() {
        try {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                    != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this,
                            Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                return
            }
            LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient,
                    locationRequest, this)
            if (location == null) {
                location = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient)
                Log.e("Your Current Locatoin :", "Lattitude is -" + location!!.getLatitude() + "\t Longitude is -" + location!!.getLongitude())
            } else {
                Log.e("Your Current Locatoin :", "Lattitude is -" + location!!.latitude + "\t Longitude is -" + location!!.longitude)
            }
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                return
            }
            LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient,
                    locationRequest, this@UpdateLocationService)

            //  sortLocationsList();
            checkForNotification()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showGpsOnAlert() {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        val pIntent = PendingIntent.getActivity(this, NOTIFICATION_ID, intent, 0)
        val builder = NotificationCompat.Builder(this)
        builder.setContentTitle("Notification")
        builder.setContentText("Please enable your Location for location updates")
        builder.setSmallIcon(R.mipmap.ic_launcher)
        builder.setAutoCancel(false)
        builder.priority = Notification.PRIORITY_HIGH
        builder.setDefaults(Notification.DEFAULT_ALL)
        builder.setContentIntent(pIntent)
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(alert, builder.build())
    }

    private fun checkForNotification() {
        if (location == null) {
            return
        } else {
            var dis = distance(location!!.latitude.toString().toFloat(), location!!.longitude.toString().toFloat(), destinationLat.toString().toFloat(), destinationLong.toString().toFloat())


            if (dis != null && dis <= 1.0) {
                showLocationNotification("you are within 1 km to you destination")
            }
            showLocationNotification("you are within 1 km to you destination")

        }
    }

    private fun showLocationNotification(msg: String) {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        Log.e("showLocation ", "showLocationNotification")
        //    if (NotificationUtils.isAppIsInBackground(getApplicationContext())) {
        val notificationIntent = Intent(this, MainActivity::class.java)
        notificationIntent.action = Constant.ACTION.MAIN_ACTION
        notificationIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        val pendingIntent = PendingIntent.getActivity(this, 13, notificationIntent, 0)
        val mNotificationManager = mContext!!
                .getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val androidChannel = NotificationChannel("notification_channel_id",
                    "notification_channel_name", NotificationManager.IMPORTANCE_HIGH)
            // Sets whether notifications posted to this channel should display notification lights
            androidChannel.enableLights(false)
            androidChannel.canShowBadge()
            androidChannel.importance = NotificationManager.IMPORTANCE_HIGH
            androidChannel.enableVibration(false)
            mNotificationManager.createNotificationChannel(androidChannel)
        }
        val mBuilder = NotificationCompat.Builder(this)
                .setLargeIcon(BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher))
                .setPriority(Notification.DEFAULT_VIBRATE)
                .setContentTitle("test")
                .setSound(uri)
                .setContentText("you are within 1 km to you destination")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .setChannelId("notification_channel_id")
                .setDefaults(Notification.DEFAULT_SOUND or Notification.DEFAULT_LIGHTS or Notification.DEFAULT_VIBRATE)
                .setAutoCancel(true)
        startForeground(FOREGROUND_SERVICE, mBuilder.build())
        //  }
    }

    private fun distance(lat_a: Float, lng_a: Float, lat_b: Float, lng_b: Float): Double {
        val earthRadius = 3958.75
        val latDiff = Math.toRadians(lat_b - lat_a.toDouble())
        val lngDiff = Math.toRadians(lng_b - lng_a.toDouble())
        val a = Math.sin(latDiff / 2) * Math.sin(latDiff / 2) +
                Math.cos(Math.toRadians(lat_a.toDouble())) * Math.cos(Math.toRadians(lat_b.toDouble())) *
                Math.sin(lngDiff / 2) * Math.sin(lngDiff / 2)
        val c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        val distance = earthRadius * c
        val meterConversion = 1609.0
        val dis = distance * meterConversion

        return dis / 1000
    }

    override fun onTaskRemoved(rootIntent: Intent) {
        val intent = Intent(applicationContext, UpdateLocationService::class.java)
                .setAction(Constant.ACTION.STOPFOREGROUND_ACTION)
        stopService(intent)
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        stopService(Intent(applicationContext, UpdateLocationService::class.java))
        Log.e(TAG, "On Distroyed fired------------+++++++++++++++-------------")
        timer!!.cancel()
        timerTask!!.cancel()
        stopForeground(true)
        stopSelf()
    }

    override fun onConnected(p0: Bundle?) {
        val builder = LocationSettingsRequest.Builder()
                .addLocationRequest(locationRequest!!)
        builder.setAlwaysShow(true) // this is the key ingredient
        val result = LocationServices.SettingsApi
                .checkLocationSettings(mGoogleApiClient, builder.build())
        result.setResultCallback(ResultCallback { result ->
            val status = result.status
            when (status.statusCode) {
                LocationSettingsStatusCodes.SUCCESS -> {
                    // All location settings are satisfied. The client can
                    // initialize location requests here.
                    if (ActivityCompat.checkSelfPermission(applicationContext, Manifest.permission.ACCESS_FINE_LOCATION)
                            != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(applicationContext,
                                    Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        return@ResultCallback
                    }
                    LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient,
                            locationRequest, this@UpdateLocationService)
                }
                LocationSettingsStatusCodes.RESOLUTION_REQUIRED -> {
                }
                LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE -> {
                }
            }
        })
    }

    override fun onConnectionSuspended(p0: Int) {
    }

    override fun onConnectionFailed(p0: ConnectionResult) {
    }

    override fun onLocationChanged(p0: Location?) {
        this.location = p0
    }


}

    
