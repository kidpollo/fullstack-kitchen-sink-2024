import React, { useState, useRef, useEffect } from "react";
import { Swipeable } from "react-native-gesture-handler";
import { Hoverable } from "./Hoverable";
import { Button, Input, Checkbox, CheckIcon, Icon, TrashIcon } from "@gluestack-ui/themed";

let timer = null;
const TIMEOUT = 500
const debounce = (onSingle, onDouble) => {
    if (timer) {
        clearTimeout(timer);
        timer = null;
        onDouble();
    } else {
        clearTimeout(timer);
        timer = setTimeout(() => {
            timer = null;
            onSingle();
        }, TIMEOUT);
    }
};

const SwipeableContainer = ({
    todo,
    todos,
    setTodos,
    swipedItemId,
    setSwipedItemId,
}: any) => {
    const [isOpen, setIsOpen] = useState(false);
    const [lastTap, setLastTap] = useState(null);
    const [editItem, setEditItem] = useState(todo.task);
    const [editItemId, setEditItemId] = useState(null);
    const swipeableRef = useRef<any>(null);
    const inputRef = useRef<any>(null);

    useEffect(() => {
        if (swipedItemId !== null && swipedItemId !== todo.id) {
            swipeableRef.current.close();
        }
    });

    const handleDelete = (id: any) => {
        const updatedTodos = todos.filter((todo: any) => todo.id !== id);
        setTodos(updatedTodos);
    };
    const toggleCheckbox = (id: any) => {
        const updatedTodos = todos.map((todo: any) =>
            todo.id === id ? { ...todo, completed: !todo.completed } : todo
        );
        setTodos(updatedTodos);
    };
    const handleEdit = (id: any) => {
        setEditItemId(null);
        if (editItem !== "") {
            const updatedTodos = todos.map((todo: any) =>
                todo.id === id ? { ...todo, task: editItem } : todo
            );
            setTodos(updatedTodos);
        } else {
            setEditItem(todo.task);
        }
    };

    const handleSingleTap = () => {};
    const handleDoubleTap = () => {
        setEditItemId(todo.id);
        setTimeout(() => {
            inputRef.current.focus();
        }, 100);
    };
    const handleSwipeAreaTap = () => { debounce(handleSingleTap, handleDoubleTap) };

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
                <Icon as={TrashIcon} name="trash" size={18} />
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
            friction={1}>
            <Hoverable
                px="$6"
                py="$1"
                minHeight={38}
                flexDirection="row"
                bg={isOpen ? "$backgroundDark700" : "$backgroundDark900"}
                focusable={false}
                onPress={handleSwipeAreaTap}>

                <Checkbox
                    aria-label={todo.id}
                    isChecked={todo.completed}
                    onChange={() => toggleCheckbox(todo.id)}
                    size="sm"
                    alignSelf="center"
                    borderColor="transparent">
                    <Checkbox.Indicator>
                        <Checkbox.Icon color="$backgroundDark900" as={CheckIcon} />
                    </Checkbox.Indicator>
                </Checkbox>

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
                    h={22}>
                    <Input.Input
                        pl="$2"
                        editable={!isOpen && editItemId === todo.id}
                        value={editItem}
                        color="$textDark50"
                        fontSize="$sm"
                        fontWeight="$normal"
                        textDecorationLine={todo.completed ? "line-through" : "none"}
                        onChangeText={(val: any) => setEditItem(val)}
                        onBlur={() => handleEdit(todo.id)}
                        autoComplete="off"
                        ref={inputRef} />
                </Input>
            </Hoverable>
        </Swipeable>
    );
};
export { SwipeableContainer };
