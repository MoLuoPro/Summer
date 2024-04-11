<script setup>
import { ref, defineEmits } from 'vue';
import axios from 'axios';

const emit = defineEmits(['submit'])

const user = ref({
    username: '',
    password: ''
});

function submit() {
    axios.post('/api/login', user).then(res => {
        emit('login', res.data);
    });
}
</script>

<template>
<el-container>
    <el-main>
        <el-form :v-model="user" label-width="auto">
            <el-form-item label="用户名">
                <el-input v-model="user.username"/>
            </el-form-item>
            <el-form-item label="密码">
                <el-input v-model="user.password"/>
            </el-form-item>
            <el-form-item>
                <div class="loginBtn" @click="submit">
                    <el-button>登录</el-button>
                </div>
            </el-form-item>
        </el-form>
    </el-main>
</el-container>
</template>

<style>
.loginBtn{
    width: 100%;
    text-align: center;
}
</style>