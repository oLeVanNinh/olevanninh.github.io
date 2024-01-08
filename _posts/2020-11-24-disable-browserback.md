---
title: "How to disable the browser back button in JS?"
tags:
  - javascript
  - work
---
## Introduction
Back to the previous page is natively controlled by your browser, it's not a good idea for the client site perform to prevent browser back, but sometimes you have a valid reason to do that. In this post, I will show you some ways to achieve this purpose, in case I have to do the same thing in the same situation and some of my experience.

## Implementation

The idea to prevent browser back in Javascript is when you detect user has click back button event and then you can inhibit page navigate to the previous page.
There is some way to do that

#### Use the popstate event

From [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Window/popstate_event)
> The popstate event will be triggered by doing a browser action such as a click on the back or forward button (or calling history.back() or
 history.forward() in JavaScript).

To use `popstate` we do as following:
```javascript
history.pushState(null, null, null);

window.addEventListener('popstate', () => {
  history.pushState(null, null, null);
  alert("If you go back to the previous page, please back from the return to the previous button.");
});
```
Firstly we use `pushState` to create a new history entry, and it becomes the current position in the history stack because I would change nothing, so the page looks
the same. After that, if users press the back button from the browser, an event `popstate` will fire and we can catch it. Code inside in the event handle block
creates the infinite loop, whenever an entry is popped from the state stack, create a new entry and push it into the history stack, after that shows an alert to the user,
it easy to understand.

This solution works fine. But there is some lesson I learn along the way:

* **If you want to show alert to all browser, don't use the built-in function:** almost browser works fine unless you use it in safari mobile for some reason after push the new state safari mobile won't show an alert on the screen. It's better to build it on your own or use another library like [BootboxJS](http://bootboxjs.com/)

* **Chrome will not allow firing popstate event unless it has user interaction** for some unknown reason :shit: chrome does not allow popstate event fire if
at least the user has interacted with the page like click, scroll,...There is a workaround is simulated by use `history.forward` and `history.back()` to allow the browser to trigger popstate event, it works fine until it has fixed in chrome version 87, f*ck that! The script below is how to use it:

```javascript
history.pushState(null, null, location.href); // Push new history entry to stack
history.back(); // Back to pevious page
history.forward(); // Forward to next page

window.addEventListener('popstate', () => {
  history.go(1);
  alert("If you go back to the previous page, please back from the return to the previous button.");
}
```

Due to `popstate` both fire on `forward` and `back`, there is a little improvement to just show alert one time if use press back:
```javascript

history.pushState(null, null, location.href);
history.back();
history.forward();
var count = 0
var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
window.addEventListener('popstate', () => {
  count++;
  history.go(1);

  if (count % 2 === 1 && (isSafari || count > 2)) { // In other browser, the first time user press back value of count is > 2, but safari is not
    alert("If you go back to the previous page, please back from the return to the previous button.");
  }
};
```
