let users = []

// addUser, removeUser, getUser, getUsersInRoom

const addUser = ({ id, username, room}) => {

    //validate data
    if (!room || !username) {
        return {
            error: 'Username , room and email must be provided'
        }
    }

    const existingUser = users.find((user) => {
        return user.id === id
    })

    if(existingUser) {
        existingUser.room = room
        return {
            error: 'Already have user'
        }
    }

    const user = { id, username, room}
    users.push(user)
    return { user }
}

const removeUser = (id) => {
    const user = getUser(id)
    const newUsers = users.filter((user) => user.id !== id)
    users = newUsers
    return user
}

const getUser = (id) => {
    return users.find((user) => user.id === id)
}

const getUsersInRoom = (room) => {
    return users.filter((user) => user.room === room)
}

const changeRoom = (id, room) => {
    for (let i = 0; i < users.length; i++) {
        if (users[i].id === id) {
            users[i].room = room
            return
        }
    }
}

module.exports = {
    addUser,
    removeUser,
    getUser,
    getUsersInRoom,
    changeRoom
}

