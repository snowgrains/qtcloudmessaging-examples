package com.kaltiot.smartgatewayapi;

public interface KaltiotSmartGatewayApiCallbacks {
    public void state_callback(int state, int error);
    public void rid_callback(String address, String rid);
    public void appid_callback(String address, String appid);
    public void notification_callback(String address, byte[] payload,
                                      int payload_type, String msg_id);
}
