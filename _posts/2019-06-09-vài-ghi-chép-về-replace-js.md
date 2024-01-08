---
title:  Vài ghi chép về replace function JS
subtitle:
tags:
   - javascript
   - replace
   - replace callback
   - work
comments: true
---

Việc xử lý `String` là việc được thực hiện khá nhiều trong lập trình, một trong các thao tác thực hiện trong số đó là `replace String`. Trong ngôn ngữ `Javascript`,
method được dùng để xử lý là `replace`, là một Standard built-in method của `String`. Tài liệu về cách sử dụng được viết đầy đủ [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace), tóm tắt lại cơ bản như sau:

```javascript
/*
Syntax sử dụng:
 var newStr = str.replace(keyword || Regex, newSubstr || function)
Phần đầu có thể truyền vào là một chuỗi String hoặc Regex, phần sau sẽ
là chuỗi String để thay thế hoặc một callback function Callback functions
sẽ nhận vào 3 parameter là match, offset và string ban đầu.
*/
'hello world'.replace('h', 'H') // Hello world

'hello world'.replace(/l/g, 'n') // henno wornd"

'hello world'.replace(/l/g, function(match, offset, string) {
  console.log(`Matching: ${match}, offset: ${offset}, string: ${string}`)
  return 'n'
})
/*
Matching: l, offset: 2, string: hello world
Matching: l, offset: 3, string: hello world
Matching: l, offset: 9, string: hello world
"henno wornd"
*/
```
## Problem

Sự thật là sẽ chẳng có cái bài viết này cho đến khi tui có làm một task nho nhỏ là highlight keyword của kết quả search trả về.
Function ban đầu trả như sau chỉ đơn giản như sau:

```javascript
  var s_tag = '<span class="search-result">';
  var e_tag = '</span>';

  String.replace(keyword, s_tag + keyword + e_tag);

  "Everything is Illuminated".replace("E", s_tag + "E" + e_tag);
//"<span class="search-result">E</span>verything is Illuminated"
```

Nếu chỉ dừng lại ở đây thì mọi thứ đều tốt đẹp và chẳng có gì để làm tiếp, cho đến khi tui quyết định mở rộng nó thành highlight toàn bộ keyword match và bất kể là có sensetive hay không.
Ban đầu tui nghĩ mọi chuyện khá là đơn giản, chỉ việc match toàn bộ keyword, sau đó lần lượt replace từng thằng một:

```javascript
function keyword_highlighting(keyword, string) {
  const pattern = new RegExp(keyword, 'gi');
  let matches = string.match(pattern);
  // Chắc chắn ko bị duplicate thằng nào.
  matches = [...new Set(matches)];

  matches.forEach(function(match) {
    let matching_pattern = new RegExp(match, 'g');
    string = string.replace(matching_pattern, s_tag + match + e_tag);
    console.log(string)
  });

  return string;
}

string = "Everything is Illuminated"
keyword_highlighting("i", string)
// Everything is Illuminated
// Thật ra là chỗ mấy chữ i cho hiển thị có đổi màu chút xíu 😌

keyword_highlighting("e", string)
// earch-result">Everything is Illuminated
// WTF 😳😳😳
```

Vấn đề nằm ở chỗ là khi keyword tồn tại trong cả `s_tag` và `e_tag` thì ở chỗ phần `forEach` chạy sẽ replace cả keyword nằm trong thẻ đó.
Khi keyword là `e` thì kết quả function trả về thật sự sẽ là:

`<span class="s<span class="search-result">e</span>arch-r<span class="search-result">e</span>sult">E</span>v<span class="search-result">e</span>rything is Illuminat<span class="search-result">e</span>d`


## Solution

Biết được nguyên nhân rồi thì đi tìm giải pháp, giải pháp đầu tiên tui nghĩ ra là viết một đoạn `Regex` sao cho không nó không match với các keyword nằm trong thẻ `tag`.
Sau một hồi suy nghĩ rồi, rồi lấy gương ra soi, nhìn thật kĩ mặt mình, tui nhận ra là tui đ** đủ khả năng để viết 🙁, bạn nào tình cờ đọc qua viết được thì có thể comment xuống dưới nha.
Cuối cùng thì tui chọn giải pháp đơn giản hơn, là tui sẽ match cả thẻ `tag` và `keyword`, nhưng lúc replace sẽ kiểm tra xem nếu đó là `tag` thì sẽ return về chính nó, để làm được điều này cũng
phải nhờ đến sự magic của callback trong replace 🤗. Implement phần này viết lại `function` như sau:

```javascript
  function keyword_highlighting(keyword, string) {
    var pattern = new RegExp(keyword, "gi");
    let matches = string.match(pattern);
    matches = [...new Set(matches)];

    matches.forEach(function(match){
      let matching_pattern = new RegExp(`<[^<>]+>|${match}`, "g");
      string = string.replace(matching_pattern, function(matched) {
        return matched[0] == '<' ? matched : (s_tag + matched + e_tag)
      })
    });

    return string;
  }

keyword_highlighting('e', string)
// Everything is Illuminated
// Working fine
```
## Conclusion

Callback trong `JS` là thứ vô cùng mạnh mẽ, như tui nghĩ sẽ chẳng bao giờ sẽ phải dùng đến callback trong replace vì như trên đã đủ rồi, nhưng trong nhiều trường hợp nó lại giúp
giải quyết vẫn đề đơn giản hơn nhiều. Như ông thầy tui bảo: "Sẽ có một ngày thứ em nghĩ là không dùng đến sẽ cứu em" sau khi thầy xem xong bộ phim `Người trở về từ sao Hỏa` 😎.
