package com.example.bluetoothmodule

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class BaseActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_base)
//        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
//            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
//            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
//            insets
//        }
//        initRcView()
        supportFragmentManager.beginTransaction().replace(R.id.placeHolder, DeviceListFragment()).commit()
    }
//    private fun initRcView(){
//        val rcView = findViewById<RecyclerView>(R.id.rcViewParied)
//        rcView.layoutManager = LinearLayoutManager(this)
//        val adapter = ItemAdapter()
//        rcView.adapter = adapter
//        adapter.submitList(createDevicesList())
//    }
//
//    private fun createDevicesList(): List<ListItem>{
//        val list = ArrayList<ListItem>()
//        for (i in 0 until 5 ){
//            list.add(
//                ListItem("Devices $i", "34:34:54:12")
//            )
//        }
//        return list
//    }
}