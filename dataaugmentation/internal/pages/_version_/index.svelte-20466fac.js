import{S as r,i as c,s as i}from"../../chunks/index-307525cc.js";import{m as u}from"../../chunks/navigation-d32ded51.js";import{b as a}from"../../chunks/paths-396f020f.js";const f=!0;async function p({params:e,fetch:t}){const{version:o}=e,n=`${a}/api/${o}`,s=u(n,{},t);return await s.load("config"),{status:301,redirect:`${a}/${o}/${s.documents.config.defaultDocument}`}}class $ extends r{constructor(t){super(),c(this,t,null,null,i,{})}}export{$ as default,p as load,f as prerender};