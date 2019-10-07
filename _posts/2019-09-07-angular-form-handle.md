---
layout: post
title:  Form validation trong Angular
subtitle:
tags: [angular]
comments: true
---

Hầu hết các ứng dụng web đều dựa vào form để nhận data, nội dung của bài viết này là giới thiệu cách validate dữ liệu trong với form trong angular. Phần code mẫu có thể dowload tại [đây](https://github.com/oLeVanNinh/angular/tree/master/login)

## 1. Chuẩn bị

Để chuẩn bị ta tạo file `user.model.ts` dưới folder `app` với nội dung như sau:


```javascript
export class User {
  username: string;
  password: string;
}
```

Sửa đổi 2 file `app.component.ts` và `app.component.html` với nội dung lần lượt:

```javascript
// app.component.ts
import { Component } from '@angular/core';
import { User } from "./user.model";
import { UserFormGroup } from "./form.model";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  user: User = new User();
}

// app.component.html

<div class="container">
  <form>
    <div class="imgcontainer">
      <img src="{{'assets/images/img_avatar2.png'}}" alt="">
    </div>
    <div class="form-field">
      <div class="form-group">
        <label>UserName</label>
        <input type="text" #username="ngModel"  class="form-control" placeholder="Enter Username" [(ngModel)]="user.username">
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" class="form-control" placeholder="Enter password" [(ngModel)]="user.password">
      </div>
      <button class="btn btn-success" type="button">Login</button>
      <button class="btn btn-danger" type="button">Cancel</button>
    </div>
  </form>
</div>
```

Cộng với việc sửa đổi một chút `CSS` thì page sẽ trông như thế này:

![](/img/angular/sample.png)

### 2. Form validation

Angular hỗ trợ việc validate content của form dựa trên chuẩn HTML5, có 4 thuộc tính có thể sử dụng để thêm cho thẻ `input`, mỗi thuộc tính sẽ định nghĩa
cho một quy tắc validation.

| Thuộc tính | Mô tả |
| :------ |:--- |
| required | Thuộc tính dùng để chỉ định giá trị phải được cung cấp |
| minlength | Thuộc tính sử dụng để quy định số ký tự tối thiểu |
| maxlength | Thuộc tính sử dụng để quy định số ký tự tối đa |
| pattern | Dùng để chỉ định một đoạn regular expresion để validate giá trị mà người dùng nhập vào |

Khi sử dụng validation trong angular ta thêm thuộc tính `novalidate` vào trong thẻ form tắt validation được hỗ trợ bởi HTML5. Validation bằng angular ta phải sử
dụng thêm thuộc tính `name` để angular phân biệt được các element trong một form. Trong trường hợp này ta validate 2 trường là username và password như sau:

```html
<!-- Username -->
 <input type="text" name="username" class="form-control" placeholder="Enter Username" [(ngModel)]="user.username" required minlength="6" pattern="^([\d\w]+@[\d\w]+\.[\d\w]+)$">

<!-- Password -->
 <input type="password" name="password" class="form-control" placeholder="Enter password" [(ngModel)]="user.password">
```

Angular sẽ tự động thêm các class tương ứng vào vào các thẻ `input`. Có tất cả 3 cặp class tương ứng:

| Tên | Mô tả |
| :------ |:--- |
| ng-untouched  ng-touched | Một element sẽ được gán cho class ng-untouched nếu người dùng chưa từng thao tác với element đó, thường là click hoặc tab vào, một khi người dùng đã thao tác, element đó sẽ được gán class ng-touched |
| ng-pristine ng-dirty | Element sẽ được gán class ng-pristine nếu nó chưa từng được thay đổi và ngược lại là ng-dirty nếu nội dung đã được thay đổi |
| ng-valid ng-invalid | Element sẽ được gán thuộc tính ng-invalid nếu giá trị của nó không thoả mãn các điều kiện validation, nếu thoản mãn nó sẽ được gán cho class ng-valid |

Ta có thể sử dụng các class này để style cho các element tương ứng để user có thể nhận biết là giá trị mình nhập vào đã hợp lệ hay chưa. Ví dụ trong trường hợp này, để người dùng biết
trường đã nhập vào gía trị đã hợp lệ thì border sẽ có màu xanh và chưa hợp lệ sẽ có border là đỏ ta thêm CSS như sau:

```html
<!-- app.component.html -->

<style>
  input.ng-dirty.ng-invalid { border: 1px solid #ff0000 }
  input.ng-dirty.ng-valid { border: 1px solid #6bc502 }
</style>
```

Angular tự động validate khi giá trị của element thay đổi, và vì thế giá trị của cách class gán cho element cũng thay đổi theo sau các event focus hay keypress. Trình duyệt sẽ tự động
phát hiện thay đổi và áp dụng class tương ứng giúp cũng cấp feedback cho người dùng mỗi khi nhập dữ liệu vào form

![](/img/angular/validate.png)

### 3.Hiện thị validation error message

Sử dụng màu sắc để cung cấp feedback cho người dùng đôi khi là không đủ, vì nhiều trường hợp dữ liệu nhập vào không hợp lệ nhưng người dùng lại không biết mình
sai ở đâu. Angular cho phép ta truy cập và xem trạng thái validation của từng element. Trong trường hợp này ta cần phải gán định danh cho element, ví dụ đối với
trường input username ta thêm `#name="ngModel"` và sử dụng angular debug:

```html
<input type="text" name="username" #name="ngModel" .....

<pre>{{ name.errors | json }}</pre>
```
![](/img/angular/errors.png)

Ta thấy error chính là một object, ta lần lượt có thể duyệt qua các key của object này và lần lượt thêm cách message validation tương ứng để hiện thị như sau:

```javascript
//app.component.ts

  getValidationMessages(state: any, thingName?: string) {
    let thing: string = state.path || thingName;
    let messages: string[] = [];
    if (state.errors) {
      for (let errorName in state.errors) {
        switch (errorName) {
          case "required":
            messages.push(`You must enter a ${thing}`);
            break;
          case "minlength":
            messages.push(`A ${thing} must be at least ${state.errors['minlength'].requiredLength} characters`);
              break;
          case "pattern":
            messages.push(`The ${thing} contains illegal characters`);
            break;
        }
      }
    }
    return messages;
  }
```
Lần lượt hiển thị error message ở views:

```html
<!-- app.component.html -->

<input type="text" name="username" #name="ngModel" .....
<ul *ng="name.dirty && name.invalid">
  <li *ngFor="let error of getValidationMessages(name)">
    {{error}}
  </li>
</ul>
```
Và kết quả thu được:

![](/img/angular/messages.png)
