package com.example.bluetoothmodule.bluetooth

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import java.io.IOException
import java.util.UUID

class ConnectThread(private val device: BluetoothDevice): Thread() {
    private val uuid = "00001101-0000-1000-8000-00805F9B34FB"
    private var mSocket: BluetoothSocket? = null
    init {
        try {
            mSocket = device.createRfcommSocketToServiceRecord(UUID.fromString(uuid))
        } catch (e: IOException){
            // слежка если не получилось подключится
        } catch (e: SecurityException){

        }
    }

    override fun run() {
        try {
            mSocket?.connect()
        } catch (e: IOException){
            // слежка на разрыв подключения
        } catch (e: SecurityException){

        }
    }

    fun closeConnection(){
        try {
            mSocket?.close()
        } catch (e: IOException){
            // слежка на разрыв подключения
        }
    }
}