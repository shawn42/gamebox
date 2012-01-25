module BBHelpers
  def min(a,b)
    a < b ? a : b
  end
  def max(a,b)
    a > b ? a : b
  end

  def union_bb_area(bb, rect)
    rleft = bb.left
    rtop = bb.top
    rright = bb.right
    rbottom = bb.bottom
    r2 = Rect.new_from_object(rect)

    rleft = min(rleft, r2.left)
    rtop = min(rtop, r2.top)
    rright = max(rright, r2.right)
    rbottom = max(rbottom, r2.bottom)

    (rright - rleft) * (rbottom - rtop)
  end

  def union_bb(bb, rect)
    # TODO can this be changed to actually update bb?
    rleft = bb.left
    rtop = bb.top
    rright = bb.right
    rbottom = bb.bottom
    r2 = Rect.new_from_object(rect)

    rleft = min(rleft, r2.left)
    rtop = min(rtop, r2.top)
    rright = max(rright, r2.right)
    rbottom = max(rbottom, r2.bottom)

    Rect.new(rleft, rtop, rright - rleft, rbottom - rtop)
  end
end

