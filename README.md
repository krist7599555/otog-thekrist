# rbnput-darwin-minimal

ไลบรารี Ruby ขนาดเล็กสำหรับตรวจจับการกดแป้นพิมพ์บนระบบ macOS โดยใช้ FFI เชื่อมต่อกับ system library ของ Darwin โดยตรง

## คุณสมบัติ

- ตรวจจับการกดคีย์แบบ low-level
- ใช้ FFI เชื่อมต่อกับ Carbon / IOKit
- ไม่มี dependency หนัก
- โค้ดสั้นและเข้าใจง่าย เหมาะสำหรับเรียนรู้หรือฝังใช้งานในโปรเจคเล็กๆ


## ตัวอย่างการเริ่ม listener เพื่อรับ keycode

```ruby
require "rbnput"
listener = Rbnput::Listener.new
listener.on_press do |key|
  puts "Key up   : #{key}"
end
listener.on_release do |key|
  puts "Key down : #{key}"
end

listener.start
listener.join
```

## ข้อจำกัด
	•	รองรับเฉพาะ macOS (Darwin)
	•	ต้องรันบน Ruby ที่รองรับ ffi
	•	ต้องมีสิทธิ์ “Input Monitoring” ใน System Settings

## การให้สิทธิ์ (Permissions)
	1.	เปิด System Settings
	2.	ไปที่ Privacy & Security
	3.	เลือก Input Monitoring
	4.	เพิ่ม Ruby หรือ Terminal ที่ใช้รันโปรแกรมของคุณเข้าไป

## โฟล์

- [./lib/rbnput/darwin_listener.rb | Most Of Implement](./lib/rbnput/darwin_listener.rb)
- [./lib/rbnput.rb | Lib Endpoint](./lib/rbnput.rb)
- [./lib/rbnput/key_code_const.rb | All Key Map](./lib/rbnput/key_code_const.rb)
- [./lib/rbnput/key_code.rb | Class KeyCode(vk, is_media)](./lib/rbnput/key_code.rb)
- [./lib/rbnput/darwin_ffi.rb | SystemLibrary Bind FFI](./lib/rbnput/darwin_ffi.rb)
- [./lib/rbnput/simple_mutex_thread.rb | Boring Thread Implement](./lib/rbnput/simple_mutex_thread.rb)