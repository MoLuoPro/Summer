<script setup>
import { ref } from 'vue';
import Login from './components/Login.vue';
import Chatroom from './components/Chatroom.vue';

const isLogin = ref(false);

function user(user) {
  if(user){
    isLogin.value = true;
  }
}
</script>

<template>
<Login v-if="!isLogin" @login="user"></Login>
<Chatroom v-else></Chatroom>
</template>

<style scoped>
</style>
