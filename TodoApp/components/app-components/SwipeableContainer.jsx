import React, { useState, useRef, useEffect } from "react";
import { Swipeable } from "react-native-gesture-handler";
import {EvilIconsIcon} from "react-native-vector-icons";
import { Hoverable } from "./Hoverable";
import { Button, Input, InputField,Checkbox, CheckIcon, Icon } from "@gluestack-ui/themed";

const SwipeableContainer = ({
  todo,
  todos,
  setTodos,
  swipedItemId,
  setSwipedItemId,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [lastTap, setLastTap] = useState(null);
  const [editItem, setEditItem] = useState(todo.task);
  const [editItemId, setEditItemId] = useState(null);
  const swipeableRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    if (swipedItemId !== null && swipedItemId !== todo.id) {
      swipeableRef.current.close();
    }
  });

  const handleDelete = (id: any) => {
    const updatedTodos = todos.filter((todo) => todo.id !== id);
    setTodos(updatedTodos);
  };
  const toggleCheckbox = (id: any) => {
    const updatedTodos = todos.map((todo) =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    );
    setTodos(updatedTodos);
  };
  const handleEdit = (id: any) => {
    setEditItemId(null);
    if (editItem !== "") {
      const updatedTodos = todos.map((todo) =>
        todo.id === id ? { ...todo, task: editItem } : todo
      );
      setTodos(updatedTodos);
    } else {
      setEditItem(todo.task);
    }
  };
  const handleDoubleTap = () => {
    const now = Date.now();
    if (!lastTap) {
      setLastTap(now);
    } else {
      if (now - lastTap < 700) {
        setEditItemId(todo.id);
        setTimeout(() => {
          inputRef.current.focus();
        }, 100);
      }
      setLastTap(null);
    }
  };
  const handleSwipeStart = () => {
    if (todo.id !== swipedItemId) setSwipedItemId(todo.id);
    setIsOpen(true);
  };

  const handleSwipeClose = () => {
    setSwipedItemId(null);
    setIsOpen(false);
  };

  const renderRightActions = () => {
    if (swipedItemId !== null && swipedItemId !== todo.id) {
      return null;
    }
    return (
      <Button
        zIndex={9999}
        h="$full"
        p="$3"
        bg="$error900"
        borderRadius="$none"
        onPress={() => handleDelete(todo.id)}
        focusable={false}
      >
        <Icon as={EvilIconsIcon} name="trash" size={18} />
      </Button>
    );
  };

  return (
    <Swipeable
      key={todo.id}
      onSwipeableWillOpen={handleSwipeStart}
      onSwipeableWillClose={handleSwipeClose}
      renderRightActions={renderRightActions}
      ref={swipeableRef}
      friction={1}
    >
      <Hoverable
        px="$6"
        py="$2"
        minHeight={38}
        flexDirection="row"
        bg={isOpen ? "$backgroundDark700" : "$backgroundDark900"}
        key={todo.id}
        alignItems="center"
        focusable={false}
        onPress={handleDoubleTap}
      >
        <Checkbox
          aria-label={todo.id}
          isChecked={todo.completed}
          value={todo.task}
          onChange={() => toggleCheckbox(todo.id)}
          size="sm"
          w="$full"
          borderColor="transparent"
        >
          <Checkbox.Indicator>
            <Checkbox.Icon color="$backgroundDark900" as={CheckIcon} />
          </Checkbox.Indicator>
          <Input
            sx={{
              ":focus": {
                _web: {
                  boxShadow: "none",
                },
              },
            }}
            borderWidth="$0"
            w="$full"
            h={22}
          >
            <InputField
              pl="$2"
              editable={!isOpen && editItemId === todo.id}
              value={editItem}
              color="$textDark50"
              fontSize="$sm"
              fontWeight="$normal"
              textDecorationLine={todo.completed ? "line-through" : "none"}
              onChangeText={(val) => setEditItem(val)}
              onSubmitEditing={() => handleEdit(todo.id)}
              onBlur={() => handleEdit(todo.id)}
              autoComplete="off"
              ref={inputRef}
            />
          </Input>
        </Checkbox>
      </Hoverable>
    </Swipeable>
  );
};
export { SwipeableContainer };