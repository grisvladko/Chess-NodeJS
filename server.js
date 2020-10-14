const express = require('express')
const http = require('http')
const socketio = require('socket.io')
const { addUser, removeUser, getUser, getUsersInRoom, changeRoom } = require('./users')

const app = express()
const server = http.createServer(app)
const io = socketio(server)

server.listen(3000, () => {
    console.log('Listening on *:3000');
});

io.on('connection', (socket) => {
    console.log('New Connection')

    socket.on('join', (username, room) => {
        const { error, user } = addUser({ id: socket.id, username, room})

        if (error) { return }

        const userList = getUsersInRoom(user.room)
        socket.join(user.room)
        
        //io does it to the whole connection
        io.emit('userList', userList)
        console.log(`${user.username} joined the room`)
        console.log(socket.rooms)
    })

    socket.on('leave', (room) => {
        socket.leave(room)
        const user = removeUser(socket.id)

        if(user) {
            const userList = getUsersInRoom(user.room)
            socket.broadcast.to(user.room).emit('userDisconnected', userList)
            console.log('leave')
            console.log(socket.rooms)
        } else {
            console.log('failed to find user to remove')
        }
    })

    socket.on('invitation', (initiator, reciever, gameId) => {
        console.log('invitation')
        console.log(socket.rooms)
        socket.to(reciever).emit('userInvited', {initiator, reciever ,gameId})
    })

    socket.on('listen', (gameId) => {
         socket.join(gameId)
         console.log('listen')
         console.log(socket.rooms)
    })

    socket.on('response', (res, initiator, gameId) => {
        if (res === true) {
            //here i transfer both of the users to the same room
            const user = getUser(socket.id)
            if (user) {
                socket.leave('lobby')
                socket.join(gameId)
                socket.broadcast.to(initiator).emit('inviteAccepted', gameId)
                console.log('response')
                console.log(socket.rooms)
            }
        } else {
            //inform user that invite was declined
            socket.broadcast.to(initiator).emit('InviteDeclined')
        }
    })

    socket.on('move', (move, id) => {
        if(move && id) {
            socket.broadcast.to(id).emit('animateMove', move)
        }
    })

    socket.on('disconnect', () => {
        const user = removeUser(socket.id)
        if(user) {
            const userList = getUsersInRoom(user.room)
            socket.broadcast.to(user.room).emit('userDisconnected', userList)
        }
    })
})