package com.snowgrains.radarsensor;

import org.qtproject.qt5.android.bindings.QtApplication;
import org.qtproject.qt5.android.bindings.QtActivity;

import android.content.Context;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.snowgrains.radarsensor.KaltiotWrapper;

public class QtApp extends QtActivity
{

    public static KaltiotWrapper kaltiotWrapper = null;
    public  QtApp m_activity = null;
    private String m_rid = "";
    // Native methods in C++
    public static native void native_state_callback(String address,String state);
    public static native void native_rid_callback(String address, String rid);
    public static native void native_appid_callback(String address, String appid);
    public static native void native_notification_callback(String address, String payload,String msg_id,int payload_length,int payload_type);

    public  void init_kaltiot_wrapper() {
        m_activity.runOnUiThread(new Runnable() {
          public void run() {
              Log.d("QTAPP", "init_kaltiot_wrapper");
              // Address and id for this app
              kaltiotWrapper = new KaltiotWrapper("KaltiotService", "KaltiotAndroidRadarSensor_0001", m_activity, m_activity);

              Intent i = new Intent();
              i.setClassName("com.snowgrains.radarsensor", "com.snowgrains.radarsensor.KaltiotService");
              startService(i);

              kaltiotWrapper.doBindService("com.snowgrains.radarsensor", "com.snowgrains.radarsensor.KaltiotService");
          }
        });

    }
    public String get_rid() {
        Log.d("QTAPP", "get_rid");
        if ( kaltiotWrapper != null) {
            kaltiotWrapper.requestRID();
         }
        return m_rid;
   }
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        m_activity = this;
        Log.d("QTAPP", "onCreate");





    }
    @Override
    protected void onResume() {
        super.onResume();
                // Reconnect if Service connection has died while we were on background
        if (kaltiotWrapper != null)  {
            if (!kaltiotWrapper.isServiceConnected()){
                kaltiotWrapper.doBindService("com.snowgrains.radarsensor", "com.snowgrains.radarsensor.KaltiotService");
                }
        }
    }

    @Override
       protected void onDestroy() {
           shutdown();

           super.onDestroy();
       }

       private void shutdown() {
           if (kaltiotWrapper != null)  kaltiotWrapper.doUnbindService();
       }

   public void state_callback(String address, String state) {
       // This is called whenever the connection state changes.
       // You may update the UI to show the connection status.
       Log.d("state_callback", ""+state);
       native_state_callback(address,state);
   }

   public void rid_callback(String address, String rid) {
       m_rid = rid;
       Log.d("rid_callback", rid);
       // This is called when your device receives its unique Resource ID.
       native_rid_callback(address, rid);
   }

   public void appid_callback(String address, String appid) {
       Log.d("appid_callback", appid);
       // This is called to inform your device what is the gateway's application ID.
       // Messaging is only possible for devices sharing the same app ID.
       native_appid_callback(address, appid);
   }

    public void notification_callback(String address, String payload, int payload_length,
                int payload_type, String msg_id) {

       Log.d("notification_callback", "");
       // This is called whenever your device receives a notification.
       native_notification_callback(address, payload, msg_id, payload_length, payload_type);

       // Respond to ping.
       /*
       if (payload_type == KaltiotSmartGatewayApi.PAYLOAD_PING && address.equals("MyApp")) {
           String publish = "device_pong";
           kaltiotSmartGatewayApi.publish(publish.getBytes(), KaltiotSmartGatewayApi.PAYLOAD_PONG);
       }*/
   }
   public void value_callback(String address, String value) {
       };

}
