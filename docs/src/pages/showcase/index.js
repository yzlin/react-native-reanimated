import React from 'react';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from '@theme/Layout';
import styles from './styles.module.css';

function Filter({ expanded }) {
  const filterButton = (
    <>
      <button className="button button--secondary button--lg"> Filter ↑</button>
    </>
  );

  const filterExpanded = (
    <>
      <div></div>
    </>
  );
  return (
    <>
      {filterButton}
      {expanded ?? filterExpanded}
    </>
  );
}

function Card() {
  return (
    <>
      <article className={styles.card}>
        <div
          style={{
            backgroundColor: 'black',
            width: '380px',
            height: '470px',
          }}></div>
        <div className={styles.cardText}>
          <h2>Title</h2>
          <span>by @JakubGonet on Twitter</span>
        </div>
      </article>
    </>
  );
}

function Showcase() {
  return (
    <Layout>
      <div className={styles.container}>
        <Filter />
        <div className={styles.cardsGrid}>
          {Array.from(Array(12)).map((_, i) => (
            <Card key={i} />
          ))}
        </div>
      </div>
    </Layout>
  );
}
export default Showcase;
