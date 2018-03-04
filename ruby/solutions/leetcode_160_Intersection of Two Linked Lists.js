/**
 * Definition for singly-linked list.
 * function ListNode(val) {
 *     this.val = val;
 *     this.next = null;
 * }
 */

/**
 * @param {ListNode} headA
 * @param {ListNode} headB
 * @return {ListNode}
 */
var getIntersectionNode = function(headA, headB) {
  if (!headA || !headB) {
    return null;
  }
  if (headA.val == headB.val) {
    return headB;
  }
  var first = headA;
  var first2 = headB;
  
  while (!!headA) {
    headA.num = 1;
    headA = headA.next;
  }
  while (!!headB) {
    headB.num = headB.num + 1;
    headB = headB.next;
  }
  while (!!first) {
    if (first.num == 2) {
      return first
    }
    first = first.next;
  }
  while (!!first2) {
    if (first2.num == 2) {
      return first2
    }
    first2 = first2.next;
  }
  return null;
};
