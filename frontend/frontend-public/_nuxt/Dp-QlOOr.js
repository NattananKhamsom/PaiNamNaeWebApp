import{a6 as a,J as o,C as t}from"./DPSIKoxe.js";const i=a((n,r)=>{const e=o("user").value;if(!o("token").value)return t("/login");if(!e||e.role!=="ADMIN")return t("/")});export{i as default};
