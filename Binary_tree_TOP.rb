class Node
  @data=nil
  @left_child=nil
  @right_child=nil
  attr_accessor :data, :left_child, :right_child
  def initialize(data=nil, left_child=nil, right_child=nil)
    @data = data
    @left_child = left_child
    @right_child = right_child
  end
  #Voir pour inclure le module Comparable
end



class Tree
  @root
  attr_accessor :root
  def initialize(array)
    array.compact!
    debut = 0
    fin = (array.length) -1
    @root = build_tree(array, debut, fin)
  end

  def build_tree(array, debut, fin) #OP
    #base case
    if(debut > fin)
      return nil
    end
    array.compact!

    array.uniq!
    array.sort!

    #Transform the array into a balanced binary tree

    mid = (debut + fin) / 2

    root = Node.new(array[mid])
    root.left_child=(build_tree(array, debut, mid-1))
    root.right_child=(build_tree(array, mid+1, fin))

    return root
  end

  def insert(value, node = @root) #TODO TEST IT
    if node.left_child != nil && node.left_child.data != nil && value < node.data 
      insert(value, node.left_child)
    elsif value < node.data 
      node.left_child=(Node.new(value, nil, nil))
    end

    if node.right_child != nil && node.right_child.data != nil && value > node.data 
      insert(value, node.right_child)
    elsif value > node.data
      node.right_child=(Node.new(value, nil, nil))
    end
  end

  def find_min(node)
    if node.left_child != nil
      find_min(node.left_child)
    end
    node
  end

  #REFAIRE A LA FIN
  def delete(value, node = @root)
    #base case
    if value = node.data
      #base case 1 It's a leaf we delete
      if node.left_child == nil && node.right_child == nil
        node.data = nil
      end

      #base case 2 It go one child --> Remplace le node par le child
      if node.left_child != nil && node.right_child == nil
        node.data = node.left_child.data
        node.left_child.data = nil
        node.right_child = node.left_child.right_child
        node.left_child = node.left_child.left_child
      elsif node.right_child != nil && node.left_child == nil
        node.data = node.right_child.data
        node.right_child.data = nil
        node.left_child = node.right_child.left_child
        node.right_child = node.right_child.right_child
      end

      #base case 3 It got 2 childs
      #TESTER CETTE FUNCTION PUIS LA REFAIRE SI ÇA MARCHE PAS
      if node.left_child != nil && node.right_child!=nil
        replacement = find_min(node.right_child)
        node.data = replacement.data
        replacement.data = nil
        #si le remplaceant à un fils a droite --> dire a son parent que c'est son fils de gauche
      end
    end

    if value < node.data
      delete(value, node.left_child)
    elsif value > node.data
      delete(value, node.right_child)
    end
  end

  def find(value, node = @root) #OP
    #base case
    if node.data == value
      return node
    end

    begin
      if node.data > value && node.left_child.data != nil
        find(value, node.left_child)
      elsif node.data < value && node.right_child.data != nil
        find(value, node.right_child)
      end
    rescue => exception
      p "ERROR: Value missing"
      return 0
    end
  end

  def level_order(node = @root, queue = Array.new, no_block = Array.new, &block) #OP
    queue << node
    while queue[0] != nil
      if block_given?
        yield(queue[0])
      else
        no_block << queue[0].data
      end
      
      if queue[0].left_child != nil
        queue << queue[0].left_child
      end
      if queue[0].right_child != nil
        queue << queue[0].right_child
      end
      queue.shift
    end

    if block_given?
      return "Level Order Done"
    else
      no_block
    end
  end

  def inorder(node = @root, no_block = Array.new, &block)#OP
    if(node == nil)
      if block_given?
        return 
      else
        return no_block
      end
    end
    inorder(node.left_child, no_block, &block)
    if block_given?
      yield(node)
    else
      no_block << node.data
    end
    inorder(node.right_child, no_block, &block)
  end

  def postorder(node = @root, no_block = Array.new, &block)#OP
    if(node == nil)
      if block_given?
        return 
      else
        return no_block
      end
    end
    postorder(node.left_child, no_block, &block)
    postorder(node.right_child, no_block, &block)
    if block_given?
      yield(node)
    else
      no_block << node.data
    end
  end

  def preorder(node = @root, no_block = Array.new, &block)#OP
    #root/left/right
    if(node == nil)
      if block_given?
        return 
      else
        return no_block
      end
    end
    if block_given?
      yield(node)
    else
      no_block << node.data
    end
    preorder(node.left_child, no_block, &block)
    preorder(node.right_child, no_block, &block)
  end

  def height(node, height = 0)#OP
    save_left = 0
    save_right = 0
    if node.right_child == nil && node.left_child == nil
      return height 
    end
    if node.left_child != nil
      save_left = height(node.left_child)
    end
    if node.right_child != nil
      save_right = height(node.right_child)
    end
    return [save_left, save_right].max + 1
  end

  def depth(researched_node, actual_node = @root, depth = 0)#OP
    if actual_node == researched_node
      return depth
    end
    if researched_node.data < actual_node.data
      depth(researched_node, actual_node.left_child, depth + 1)
    elsif researched_node.data > actual_node.data
      depth(researched_node, actual_node.right_child, depth + 1)
    end
  end

  def balanced#OP
    right_height = height(root.right_child)
    left_height = height(root.left_child)
    dif = right_height - left_height
    if dif < -1 || dif > 1
      return false
    else  
      return true
    end
  end

  def rebalance#OP?
    array = Array.new
    self.inorder {|node| array << node.data }
    array.compact!
    debut = 0
    fin = (array.length) -1
    @root = build_tree(array, debut, fin)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
  end
end


test_array = Array.new(12) { rand(1..100) }
test_tree = Tree.new(test_array)
x = rand(2..10)
while x > 0
  test_tree.insert(rand(1..100))
  x-=1
end
if test_tree.balanced == false
  p "Tree rebalanced"
  test_tree.rebalance
  
end

p test_tree.balanced














