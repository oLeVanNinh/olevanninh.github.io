---
title: "Rails antipattern: Voyeuristic Models"
tags:
  - antipattern
  - refactor
---

Ruby là ngôn ngữ lập trình hướng đối tượng, Rails là framework được viết bằng Ruby xây dựng trên mô hình MVC với mã nguồn được tổ chức thành các layer Model - View - Controller. ActiveRecord là core chính của phần model, cũng cấp nhiều công cụ như callback, validation, association tiện dụng giúp việc phát triển nhanh và dễ dàng hơn, nhưng bù lại nếu ko tổ chức tốt nó có thể vi phạm những quy tắc của lập trình hướng đối tượng, tạo ra các component kết dính với nhau, gây khó khăn trong việc mở rộng và bảo trì mã nguồn sau này. Dưới đây là một số quy tắc giúp việc viết và tổ chức code trong model trở nên tối ưu hơn:

### 1. Tuân thủ định luật Demeter
Giả sử ta có model setup như sau:
```ruby
class Address < ActiveRecord::Base
  belongs_to :customer
end

class Customer < ActiveRecord::Base
  has_one :address
  has_many :invoices
end

class Invoice < ActiveRecord::Base
  belongs_to :customer
end
```

Bằng việc setup association như trên, ta có thể dễ dàng truy cập thuộc tính của các đối tượng có quan hệ với đối tượng hiện tại:

```erb
<%= @invoice.customer.name %>
<%= @invoice.customer.address.street %>
<%= @invoice.customer.address.city %>
<%= @invoice.customer.address.state %>
<%= @invoice.customer.address.zip_code %>
```
Code như trên có vẻ tiện dụng nhưng ko phải là lý tưởng, vấn đề xuất hiện khi việc main mở rộng hay thay đổi chức năng sau này. Giả sử `customer` thay đổi có thành 2 loại `address` là `billing_ađress` và `shiping_address` nhưng phần code ở bên trên để lấy thuộc tính `stress, city, zip_code` sẽ gây crash cho chương trình, và ta cần thay đổi lại toàn bộ phần đó.

Để tránh vấn đề trên, ta cần tuần thủ định luật [Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter) , định luật được tóm tắt như sau:
> * Each unit should have only limited knowledge about other units: only units "closely" related to the current unit.
> * Each unit should only talk to its friends; don't talk to strangers.
> * Only talk to your immediate friends.

Được hiểu là một đối tượng chỉ gọi các phương thức liên quan đến đối tượng đấy, mà ko gọi phương thức của một đối tượng có liên quan đối đối tượng hiển tại, hay trong Rails nghĩa là chỉ sử dụng một lần `.` duy nhất. Trong ví dụ trên thì `@invoice.customer.name` vi phạm định luật Demeter nhưng `@invoice.customer_name` thì ko, bời vậy ta có thể refactor lại source code trong model `Invoice` và `Customer` như sau:

```ruby
class Customer < ActiveRecord::Base
  has_one :address
  has_many :invoices

  def street
    address.street
  end

  def city
    address.city
  end

  #...
end

class Invoice < ActiveRecord::Base
  belongs_to :customer

  def customer_name
    customer.name
  end

  def customer_street
    customer.street
  end

  def customer_city
    customer.city
  end

  #...
end
```

Khi đó ta có thể thay đổi:

```ruby
<%= @invoice.customer_name %>
<%= @invoice.customer_street %>
<%= @invoice.customer_city %>
<%= @invoice.customer_state %>
<%= @invoice.custome_zip_code %>
```

Nhược điểm của phương pháp trên là ta phải tạo nhiều phương thức nhỏ dùng để bao đóng phần implement bên trong, nếu tương lai chương trình cần thay đổi thì ta cần phải thay đổi toàn bộ các phương thức đó, thêm nữa, ta phải tạo thêm nhiểu interface trong model `Invoice` nhưng lại ko liên quan gì đến phần còn lại của model này. Việc này ko phải vấn đề lớn khi sử dụng Rails, trong Rails có hỗ trợ phương thức `delegate` nên ta có thể viết lại như sau:

```ruby
class Customer < ActiveRecord::Base
  has_one :address
  has_many :invoices
  delegate :street, :city, :state, :zip_code, :to => :address
end

class Invoice < ActiveRecord::Base
  belongs_to :customer
  delegate :name,
           :street,
           :city,
           :state,
           :zip_code, to: :customer, prefix: true
end
```

Như vậy ta vẫn tuân thủ được định luật Demter đồng thời cũng tránh được các điểm hạn chế của nó.

## 2. Viết toàn bộ các phương thức `find()` trong Model
Rails được viết theo mô hình MVC, trong mô hình MVC, View đóng vai trò như presenter vì thế ở trong view luôn hạn việc đặt logic hay việc trích xuất dữ liệu từ View, mà chỉ sử dụng vài vòng lặp hoặc câu lệnh kiểm tra điều kiên cơ bản. Tuy nhiên, nhiều lập trình viên khi mới làm quen với Rails có thể vi phạm nguyên tắc này:

```html
<html>
  <body>
    <ul>
      <% User.find(:order => "last_name").each do |user| -%>
        <li><%= user.last_name %> <%= user.first_name %></li>
      <% end %>
    </ul>
  </body>
</html>
```
Hoặc có là chuyển từ ngôn ngữ PHP qua:
```php
<html>
  <body>
<?php
  $result = mysql_query('SELECT last_name, first_name FROM users
ORDER BY last_name') or die('Query failed: ' . mysql_error());

  echo "<ul>\n";
  while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
    echo "\t<li>$line[0] $line[1]</li>\n";
  }
  echo "</ul>\n";
?>
  </body>
</html>
```

Để tránh vi phạm mô hình MVC, ta cần đặt lại logic lấy thông tin `User` để hiển thị vào trong `Controller`:
```ruby
class UsersController < ApplicationController
  def index
    @users = User.order("last_name")
  end
end
```
Khi đó phần logic trong view sẽ đơn giản hơn:
```erb
<html>
  <body>
    <ul>
      <% @users.each do |user| -%>
        <li><%= user.last_name %> <%= user.first_name %></li>
      <% end %>
    </ul>
  </body>
</html>
```
Khi Rails mới phát triển, nhiều lập trình viên sẽ chỉ dừng lại ở đây, tuy nhiên qua thời gian, các nhà phát triển đã nhận ra lợi ích của việc tiến thêm một bước nữa là di chuyển toàn bộ truy vẫn vào trong `Model`:
```ruby
class UsersController < ApplicationController
  def index
    @users = User.ordered
  end
end

class User < ActiveRecord::Base
  def self.ordered
    order("last_name")
  end
end
```
Lợi ích của việc này là tập trung toàn bộ truy vấn vào một nơi, việc tổ chức code trở nên rõ ràng hơn, cộng đồng Ruby on Rails đã dần chấp nhận khái niệm này và đã đưa nó vào trong framework với khái niệm `scope`

```ruby
class User < ActiveRecord::Base
  scope :ordered, order("last_name")
end
```

## 3. Dữ liệu của Model nào thì truy vấn ở Model ấy
Bằng việc chuyển toàn bộ các truy vấn vào trong `Model` đã giúp tăng khả năng bảo trì của code, tuy nhiên, một lỗi mà develper hay mắc phải là di chuyển truy vấn toàn bộ vào `Model` gần nhất mà bỏ qua delegate truy vấn về các `Model` tương ứng.
Giả sử bạn có có một ứng dụng mạng xã hội và trong controlelr có sử dụng truy vấn phức tạp:

```ruby
class UsersController < ApplicationController
  def index
    @user = User.find(params[:id])
    @memberships =
    @user.memberships.where(:active => true)
                     .limit(5)
                     .order("last_active_on DESC")
  end
end
```

Dựa trên 2 phần trên bạn refactor lại như sau:
```ruby
class UsersController < ApplicationController
  def index
    @user = User.find(params[:id])
    @recent_active_memberships = @user.find_recent_active_memberships
  end
end

class User < ActiveRecord::Base
  has_many :memberships
  def find_recent_active_memberships
    memberships.where(:active => true)
               .limit(5)
               .order("last_active_on DESC")
  end
end
```

Bằng việc refactor lại như trên controller đã trở lên nhỏ gọn hơn, và tên method chỉ mục đích rõ ràng giúp code trở nên dễ đọc hơn, tuy nhiên có điểm vẫn cần cải thiện, trong phương thức `find_recent_active_memberships` biết quá nhiều về implementation của `Membership`.

Trong trường hợp này ta là sử dụng `AssociationProxy` để refactor tiếp. Mỗi khi truy vấn, Rails trả về ko phải là một Array mà là `ActiveRecord::Associations::AssociationProxy`, hoạt động như một Array, điểu đặc biệt ở đây là ta có thể gọi các method định nghĩa trên model `Membership` trên object đó. Điều đó nghĩa là giả sử ta có method `active` trên model `Membership` thì ta có thể gọi `Membership.active` hay `user.memberships.active`. Khi đó toàn bộ truy vấn liên quan đến `Mebership` model sẽ được chuyển về model tương ứng như sau:

```ruby
class User < ActiveRecord::Base
  has_many :memberships

  def find_recent_active_memberships
    memberships.find_recently_active
  end
end

class Membership < ActiveRecord::Base
  belongs_to :user

  def self.find_recently_active
    where(:active => true).limit(5).order("last_active_on DESC")
  end
end
```

`find_recently_active` chỉ thực hiện truy vấn thông thường nên trường hợp này sẽ tốt hơn nếu sử dụng `scope` thay vì `class method`. Hơn nữa vì scope là lazy evaluate và hỗ trợ trên nên ta có thể tách thành các phần scope nhỏ và đơn giản hơn:
```ruby
class Membership < ActiveRecord::Base
  belongs_to :user

  scope :only_active, where(:active => true)
  scope :order_by_activity, order('last_active_on DESC')
end

class User < ActiveRecord::Base
  has_many :memberships

  def find_recent_active_memberships
    memberships.only_active.order_by_activity.limit(5)
  end
end
```
