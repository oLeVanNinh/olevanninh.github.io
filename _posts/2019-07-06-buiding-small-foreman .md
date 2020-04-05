---
title:  Tạo script quản lý process tương tự foreman
tags:
  - ruby
comments: true
---

Trong quá trình làm việc, đổi khi dự án được chia ra thành nhiều phần như front-end và back-end, hoặc chỉ đơn giản là một project với Rails nhưng lại phải quản lý
cả phần server và worker chạy và gây khá khó chịu khi làm những dự án kiểu này là mỗi khi khởi dộng development bạn sẽ cần mở rất nhiều terminal để  khởi động từng process.
Ruby có một gem giúp giải quyết vấn đề này một cách đơn giản hơn là [foreman](https://github.com/ddollar/foreman), bằng việc chỉ cần khai báo các command cần chạy vào
`Procfile` và chỉ cần chạy command `foreman start`, mọi việc còn lại đã có `foreman` lo cho bạn.

```ruby
client: cd client && npm start
server: cd server && rails s -p 3001
```

```ruby
gem install foreman
foreman start
```

![](/img/07_08_2019/foreman_screen.png)

Nội dung của bài viết này là hướng dẫn viết lại một script nhỏ có  chức năng tương tự như `foreman`, có thể coi như minimal version.

## 1. Design của chương trình
Biểu diễn dưới dạng UML:

![](/img/07_08_2019/uml.png)

Chương trình sẽ gồm 3 class chính: `YAMLfile`, `Processer`, `StartScript`.

Trong phần này ta sẽ sử dụng `yml` thay vì `Procfile`, lý do là vì `Ruby` đã có sẵn thư viện và việc load, xử lý file `yml`
sẽ đơn giản hơn. `Class YAMLfile` có chức năng khởi tạo và load dữ liệu có trong file `yml`. `Process` có chức năng giữ và khởi tạo các `process`.
Flow chạy chính sẽ được thực hiện trong `MainScript` và được chia thành  các step chính:

* Step 1: Regist tín hiệu ngắt interrupt, cụ thể trong trường hợp này là `Ctrl + C` và xử lý khi gặp tín hiệu ngăt
* Step 2: Load và đọc các command trong file yml
* Step 3: Tạo process con tương ứng cho các command trong file yml
* Step 4: Chờ tín hiệu ngắt từ phía người dùng
* Step 5: Dừng tất cả các process con

## 2.Implement


#### YAMLfile
Phần này chỉ việc khởi tạo `class` và đọc toàn bộ file `yml` vào trong một `instance variable`, để giá trị file mặc định là `process.yml`.
```ruby
require 'yaml'

class YAMLfile
  attr_reader :entries

  def initialize(filename = "process.yml")
    @entries = load_file(filename)
  end

  def load_file(filename)
    YAML.load_file filename
  end
end
```

### Processor
Phần này sẽ tạo ra các process tương ứng cho mỗi command, ta sử dưng [Process.spawn](https://apidock.com/ruby/Kernel/spawn) để tạo các process.
Phần code sẽ làm như sau:
```ruby
class Processor
  def initialize(command, dir)
    @command = command
    @dir = cwd
  end

  def run
    Dir.chdir(@dir) do
      Process.spawn @command
    end
  end
end
```

### MainScript

Trước hết khởi tạo class với các `instance variable` lần lượt là `@process`, `@running` và `shutdown` lần lượt dùng để lưu lưu tấ t cả process, các process đang chạy và tín hiệu ngắt.
```ruby
class MainScript
  def initialize
    @processes = {}
    @running = []
    @shutdown = false
  end
end
```
Tiếp theo ta định nghĩa method `run_with_step` lần lượt chạy các step như đã nói ở phần 1:

```ruby
  def run_with_step
    register_interrupt_signal
    load_yaml_file_and_set_up
    spawn_process
    wait_for_shutdown
    kill_all_child_process
  end
```

Bây giờ lần lượt thực hiện từng step:

* **register_interrupt_signal**

Để dễ hình dung thì phần này cũng tương tự như `addEventLisner` trong `JS`, mỗi khi bắt được `event` thì thưc hiện một công việc nào đó, trong trường này thì `event` chính là tín hiệu ngắt khi
người dùng bấm `Ctrl + C` bằng cách sử dùng `Kernel` method `trap`  và xử lý tín hiệu đó. Ở phần khở tạo ta có tạo instance variable `@shutdown` phầ n này sẽ được gán giá trị là `true`.

```ruby
def register_interrupt_signal
  trap("INT") do
    handle_interrupt
  end
end

def handle_interrupt
  puts "SIGINT received, starting shutdown"
  @shutdown = true
end
```

* **load_yaml_file_and_set_up**

Khi khởi tạo `YAMLfile` ta để giá trị mặc định của file là `process.yml`, ta có thể thay đổi giá trị này bằng cách đọc từ `ARGV` nếu có truyền thêm tên file vào.

```ruby
  def load_yml_file_and_set_up
    file_name  = ARGV.find {|e| e =~ /^\w+.yml$/};
    yml_data = YAMLfile.new(file_name).entries

    yml_data.keys.each do |key|
      dir = yml_data[key]["directory"]
      command = yml_data[key]["command"]
      @processes[key] = Processor.new(command, dir)
    end
  end
```
* **spawn_process**

Thực hiện phần này cũng khá đơn giản, từ các process đã được khởi tạo trước đó, ta tạo các process tương ứng. Lưu ý ở đây là method `spawn` sinh ra process
và process được sinh ra này không đợi đến khi command kết thúc, ta lưu trữ giá trị `pid` của các process này vào variable `@running` để sử dụng cho việc
dừng các process sau này

```ruby
def spawn_process
  @processes.each do |name, process|
    @running << process.run
  end
end
```

* **wait_for_shutdown**

Ta thưc hiện bằng việc chờ bằng cách tạo một vòng lặp vô hạn, chỉ dừng lại khi `@shutdown` có giá trị bằng `true`, giá trị của `@shutdown` chỉ thay đổi khi nhận
tín hiểu `interrupt` của người sử dụng như đã implemnt ở phía trên.

```ruby
  def wait_for_shutdown
    loop do
      break if @shutdown

      begin
        sleep 1
      rescue Exception
      end
    end
  end
```

* **kill_all_child_process**

Phần này ta chỉ việc lấy tất cả process đang chạy ra và kill lần lượt từng phần process:

```ruby
def kill_all_child_process
  @running.each do |pid|
    Process.kill("HUP", pid)
  end
end
```

Reactor một chút bằng cách thêm method `start`:

```ruby
class << self
  def start
    new.start
  end
end
```

File yml:

```ruby
rails:
  command: rails s -p 3001
  directory: server
client:
  command: npm start
  directory: client
```

Sau khi chạy command `MainScript` ta cũng có kết quả tương tự

![](/img/07_08_2019/result.png)
