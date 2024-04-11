<script setup>
import { ref, onMounted } from "vue";

const sendText = ref('');
const allText = ref([]);
const socket = new WebSocket('ws://localhost:4000/chat');

onMounted(() => {
    socket.onmessage = (event) => {
        allText.value.push(event.data);
    };
});

function send(){
    socket.send(sendText.value);
}
</script>

<template>
<el-container direction="vertical">
    <el-main>
        <div class="panel">
            <el-scrollbar height="400">
                <div v-for="(text, i) in allText" :key="i">
                    <div>{{ text }}</div>
                </div>
            </el-scrollbar>
            <div class="input-panel">
                <el-input class="input" type="textarea" rows="5" v-model="sendText"/>
                <div class="send">
                    <el-button @click="send">发送</el-button>
                </div>
            </div>
        </div>
    </el-main>
</el-container>
</template>

<style scoped>
.panel{
    border: 2rem;
    width: 30rem;
    background-color: #FFF8E1;
}
.input-panel{
    background-color: #D9D9D9;
}
.input{
    width: 100%;
    height: 10rem;
}
.input >>> .el-textarea__inner{
    height: 100%;
    background-color: unset;
    box-shadow: unset;
    caret-color: aliceblue;
}
.send{
    display: flex;
    flex-direction: row-reverse;
}
.infinite-list {
  height: 300px;
  padding: 0;
  margin: 0;
  list-style: none;
}
.infinite-list .infinite-list-item {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 50px;
  background: var(--el-color-primary-light-9);
  margin: 10px;
  color: var(--el-color-primary);
}
.infinite-list .infinite-list-item + .list-item {
  margin-top: 10px;
}
</style>
